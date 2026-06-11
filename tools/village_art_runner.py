#!/usr/bin/env python3
"""One-shot orchestrator for the remaining village art (2026-06-11): the
render farm is congested, so run everything SEQUENTIALLY with retries.
Resumable — tilesets requeue on failure, props skip existing files.

Run detached: nohup python3 tools/village_art_runner.py > /tmp/village_art.log 2>&1 &
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402
import pixellab_tilesets as ts  # noqa: E402
import pixellab_village_props as props  # noqa: E402


def log(msg: str) -> None:
    print(msg, flush=True)


def wait_job(jid: str, label: str, max_polls: int = 90) -> bool:
    for _ in range(max_polls):
        try:
            status = call(f"background-jobs/{jid}", method="GET").get("status")
        except Exception as e:  # noqa: BLE001 — gateway hiccups must not kill the run
            log(f"  {label}: poll error ({str(e)[:80]})")
            time.sleep(60)
            continue
        if status == "completed":
            log(f"  {label}: completed")
            return True
        if status == "failed":
            log(f"  {label}: failed")
            return False
        time.sleep(30)
    log(f"  {label}: poll budget exhausted")
    return False


def ensure_tileset(name: str, attempts: int = 4) -> bool:
    for attempt in range(attempts):
        try:
            st = ts.state()
            info = st.get(name, {})
            jid = (info.get("raw") or {}).get("background_job_id")
            if jid:
                status = call(f"background-jobs/{jid}", method="GET").get("status")
                if status == "completed":
                    log(f"{name}: already completed")
                    return True
                if status == "processing":
                    log(f"{name}: waiting on existing job")
                    if wait_job(jid, name):
                        return True
            # (re)queue
            st.pop(name, None)
            ts.save_state(st)
            log(f"{name}: queueing (attempt {attempt + 1})")
            ts.queue(name)
            st = ts.state()
            jid = st[name]["raw"]["background_job_id"]
            if wait_job(jid, name):
                return True
        except Exception as e:  # noqa: BLE001 — 502s etc: back off, retry
            log(f"{name}: attempt {attempt + 1} error ({str(e)[:100]})")
        time.sleep(180)
    return False


def main() -> None:
    ok = True
    for name in ("village_green", "village_yard"):
        if not ensure_tileset(name):
            log(f"GIVING UP on tileset {name}")
            ok = False
    if ok:
        ts.download()
        log("tilesets downloaded")
    # props resume; --only forces regeneration, so skip existing here
    for prop_name in props.PROPS:
        if (props.OUT / f"{prop_name}.png").exists():
            log(f"{prop_name}: exists, skipping")
            continue
        for attempt in range(3):
            try:
                props.generate(prop_name)
                break
            except Exception as e:  # noqa: BLE001
                log(f"{prop_name}: attempt {attempt + 1} failed ({str(e)[:120]})")
                time.sleep(45)
    log("RUNNER DONE")
    log("balance: %s" % call("balance", method="GET")["credits"]["usd"])


if __name__ == "__main__":
    main()
