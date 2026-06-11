#!/usr/bin/env python3
"""Village art runner — tier-2 edition (priority queue, parallel slots).

Tilesets render as parallel background jobs via pixellab_jobs.run_jobs;
props are sync pixflux calls, threaded. Resumable: completed tilesets and
existing prop files are skipped.

Run detached: nohup python3 tools/village_art_runner.py > /tmp/village_art.log 2>&1 &
"""
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402
from pixellab_jobs import run_jobs  # noqa: E402
import pixellab_tilesets as ts  # noqa: E402
import pixellab_village_props as props  # noqa: E402

PENDING_TILESETS = ["village_green", "village_yard"]


def log(msg: str) -> None:
    print(msg, flush=True)


def submit_tileset(name: str) -> str:
    st = ts.state()
    st.pop(name, None)
    ts.save_state(st)
    ts.queue(name)
    return ts.state()[name]["raw"]["background_job_id"]


def tileset_done(name: str) -> bool:
    st = ts.state()
    jid = (st.get(name, {}).get("raw") or {}).get("background_job_id")
    if not jid:
        return False
    try:
        return call(f"background-jobs/{jid}", method="GET").get("status") == "completed"
    except Exception:  # noqa: BLE001
        return False


def render_prop(name: str) -> str:
    for attempt in range(3):
        try:
            props.generate(name)
            return f"{name}: ok"
        except Exception as e:  # noqa: BLE001
            log(f"{name}: attempt {attempt + 1} failed ({str(e)[:100]})")
            time.sleep(30)
    return f"{name}: GAVE UP"


def main() -> None:
    todo = [n for n in PENDING_TILESETS if not tileset_done(n)]
    if todo:
        results = run_jobs([(n, lambda n=n: submit_tileset(n)) for n in todo], log=log)
        log(f"tilesets: {results}")
    ts.download()
    log("tilesets downloaded")
    missing = [n for n in props.PROPS if not (props.OUT / f"{n}.png").exists()]
    log(f"props to render: {missing}")
    with ThreadPoolExecutor(max_workers=4) as pool:
        for future in as_completed([pool.submit(render_prop, n) for n in missing]):
            log(future.result())
    log("RUNNER DONE")
    log("balance: %s" % call("balance", method="GET")["credits"]["usd"])


if __name__ == "__main__":
    main()
