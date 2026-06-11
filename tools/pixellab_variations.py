#!/usr/bin/env python3
"""Terranigma pass renders: terrain variation tiles (tiles-pro, style-anchored
on our own ground tiles) + the grass->terrace cliff tileset (the engine's
transition-as-elevation bias used as a feature).

Usage:
  python3 tools/pixellab_variations.py queue
  python3 tools/pixellab_variations.py download
"""
import argparse
import base64
import io
import json
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402
from pixellab_jobs import run_jobs  # noqa: E402
import pixellab_tilesets as ts  # noqa: E402

OUT = Path("assets/reference/pixellab_variations")
STATE = OUT / "state.json"
TILE = 32

# variation sets: name -> (style anchor "atlas:slot", numbered description)
VARIATION_SETS = {
    "grass_variants": (
        "village_yard_tileset_32.png:0",
        "1) plain lawn grass 2) lawn grass with small white wildflowers "
        "3) lawn grass with taller tufts 4) lawn grass with a few small pebbles "
        "5) worn thinning grass patch 6) lawn grass with two tiny mushrooms"),
    "dirt_variants": (
        "village_yard_tileset_32.png:15",
        "1) plain packed dirt 2) packed dirt with faint cart wheel ruts "
        "3) packed dirt with small embedded stones 4) packed dirt with sparse straw"),
}

TERRACE_TILESET = {
    "lower_description": "village lawn grass at golden sunset, warm and tended",
    "upper_description": "raised grass terrace plateau, the same warm lawn grass on top",
    "transition_description": "low earthen cliff edge, exposed soil with embedded "
        "stones and grass roots overhanging the lip",
}


def state() -> dict:
    return json.loads(STATE.read_text()) if STATE.exists() else {}


def save_state(data: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(data, indent=1))


def queue() -> None:
    st = state()
    jobs = []
    for name, (anchor, desc) in VARIATION_SETS.items():
        if st.get(name, {}).get("id"):
            print(f"skip {name}")
            continue

        def submit(name=name, anchor=anchor, desc=desc) -> str:
            # TilesProStyleImage = raw {base64,width,height} of the NATIVE tile
            fname, idx = anchor.rsplit(":", 1)
            i = int(idx)
            atlas = Image.open(Path("assets/reference/pixellab_tilesets") / fname)
            tile = atlas.crop(((i % 4) * TILE, (i // 4) * TILE,
                               (i % 4 + 1) * TILE, (i // 4 + 1) * TILE)).convert("RGBA")
            buf = io.BytesIO()
            tile.save(buf, "PNG")
            result = call("create-tiles-pro", {
                "description": desc,
                "style_images": [{"base64": base64.b64encode(buf.getvalue()).decode(),
                                  "width": TILE, "height": TILE}],
                "style_options": {"color_palette": True, "outline": True,
                                  "detail": True, "shading": True},
            })
            st2 = state()
            st2[name] = {"id": result.get("tile_id") or result.get("id"),
                         "job": (result.get("background_job_ids") or
                                 [result.get("background_job_id")])[0]}
            save_state(st2)
            return st2[name]["job"]
        jobs.append((name, submit))
    if not st.get("village_terrace", {}).get("job"):
        def submit_terrace() -> str:
            tstate = ts.state()
            tstate.pop("village_terrace", None)
            ts.save_state(tstate)
            ts.TILESETS["village_terrace"] = TERRACE_TILESET
            ts.queue("village_terrace")
            jid = ts.state()["village_terrace"]["raw"]["background_job_id"]
            st2 = state()
            st2["village_terrace"] = {"job": jid}
            save_state(st2)
            return jid
        jobs.append(("village_terrace", submit_terrace))
    if jobs:
        print(run_jobs(jobs))
    print("balance:", call("balance", method="GET")["credits"]["usd"])


CURATE_COUNT = {"grass_variants": 6, "dirt_variants": 1}  # only the stones tile reads as dirt


def _anchor_mean(name: str) -> tuple:
    fname, idx = VARIATION_SETS[name][0].rsplit(":", 1)
    i = int(idx)
    atlas = Image.open(Path("assets/reference/pixellab_tilesets") / fname)
    tile = atlas.crop(((i % 4) * TILE, (i // 4) * TILE,
                       (i % 4 + 1) * TILE, (i // 4 + 1) * TILE)).convert("RGB")
    px = list(tile.getdata())
    n = len(px)
    return tuple(sum(c[k] for c in px) / n for k in range(3))


def _curate(name: str, raw: list) -> list:
    """tiles-pro returns 16 candidates; some are decals on transparency or
    off-palette (observed 2026-06-11). Keep full-coverage tiles closest to
    the anchor terrain's mean color."""
    target = _anchor_mean(name)
    scored = []
    for img in raw:
        data = list(img.getdata())
        opaque = [p for p in data if p[3] > 200]
        coverage = len(opaque) / len(data)
        if coverage < 0.98:
            continue
        n = len(opaque)
        mean = tuple(sum(c[k] for c in opaque) / n for k in range(3))
        dist = sum((mean[k] - target[k]) ** 2 for k in range(3)) ** 0.5
        scored.append((dist, img))
    scored.sort(key=lambda t: t[0])
    keep = [img for _d, img in scored[:CURATE_COUNT.get(name, 6)]]
    print(f"  {name}: {len(raw)} candidates -> {len(keep)} curated")
    return keep


def download() -> None:
    st = state()
    OUT.mkdir(parents=True, exist_ok=True)
    for name in VARIATION_SETS:
        tid = st.get(name, {}).get("id")
        if not tid:
            print(f"{name}: no id")
            continue
        # storage_urls 403 (B2 bucket, 2026-06-11) — the background job's
        # last_response embeds every tile as base64 instead
        job = call(f"background-jobs/{st[name]['job']}", method="GET")
        entries = (job.get("last_response") or {}).get("images") or []
        if not entries:
            print(f"{name}: no embedded images")
            continue
        raw = [Image.frombytes("RGBA", (e["width"], e["height"]),
                               base64.b64decode(e["base64"]))
               for e in entries]  # type "rgba_bytes": raw pixels, not PNG
        imgs = _curate(name, raw)
        strip = Image.new("RGBA", (TILE * len(imgs), TILE), (0, 0, 0, 0))
        for i, img in enumerate(imgs):
            strip.paste(img.resize((TILE, TILE)) if img.size != (TILE, TILE) else img,
                        (i * TILE, 0))
        path = OUT / f"{name}_{TILE}.png"
        strip.save(path)
        strip.resize((strip.width * 4, strip.height * 4), Image.NEAREST).save(
            OUT / f"{name}_preview.png")
        print(f"{name}: {path} ({len(imgs)} tiles)")
    # terrace tileset comes through the standard tileset downloader
    ts.download()


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["queue", "download"])
    args = ap.parse_args()
    {"queue": queue, "download": download}[args.cmd]()
