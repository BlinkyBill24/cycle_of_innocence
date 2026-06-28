#!/usr/bin/env python3
"""One-off driver: two Briar concept sheets -> 8-direction PixelLab sprite sets.

REUSES the proven concept->character pipeline in tools/pixellab_v2.py
(create-character-pro, method=create_from_concept) rather than re-implementing it
in the thin tools/pixellab_api.py — that pipeline already carries the debugged
magenta-key/despill/_largest_blob extraction and the backdrop-box negative prompt.
The view stays HARDCODED to the Projection Canon (low top-down, Rule 5) — never
overridden. Animation/skeleton rigging is intentionally NOT done here (out of
scope, and the documented PixelLab `animate-character` 404 wall is animate-only;
base 8-direction creation is unaffected).

Each variation:
  side-view crop -> PixelLab remove-background -> _largest_blob -> 512px concept
  -> create-character-pro (concept + established-Briar style cell) -> poll
  -> fetch the 8 stored rotation_urls -> save assets/companions/briar/<var>/*.png
  -> write params.txt (exact API payload, for reproducibility).

Usage:
  python3 tools/briar_concept_variations.py create   # POST both, save char ids
  python3 tools/briar_concept_variations.py fetch     # poll + download 8 dirs each
"""
import argparse
import base64
import importlib.util
import io
import json
import sys
import time
import urllib.request
from pathlib import Path

from PIL import Image

# reuse the proven v2 wrapper wholesale (call/keying/style-ref/state helpers)
sys.path.insert(0, str(Path(__file__).parent))
from pixellab_api import CANON_VIEW  # the single Projection-Canon view (Rule 5)  # noqa: E402
_spec = importlib.util.spec_from_file_location("pixellab_v2", Path(__file__).parent / "pixellab_v2.py")
v2 = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(v2)

OUT = Path("assets/companions/briar")
STATE = OUT / "_state.json"
SIZE = 32  # Briar's project sprite size (briar_pup_32 / briar_corrupt_32). Rule: 32 or 64.
DIRECTIONS = ["south", "south-east", "east", "north-east",
              "north", "north-west", "west", "south-west"]

# concept source crops: (image, side-view box, description). Mapping (see /goal):
#  - "corrupted" (A): the "Belgian Malinois Puppy" sheet — description drives the
#    corruption (the provided concept is a healthy puppy, NOT pre-corrupted).
#  - "adult"     (B): the healthy adult 4-direction sheet.
# Both use the EAST-facing side panel (quadruped -> side, per the v2 recipe).
IDEAS = "/home/seitanist/Documents/cycle_of_innocence_ideas"
VARIATIONS = {
    "corrupted": {
        "src": f"{IDEAS}/grok-9889dda1-f5c4-4c35-bb97-f8fe7c02c8a7.png",
        "box": (1240, 110, 1690, 440),  # top-right "C. RIGHT SIDE" puppy panel
        "description": "corrupted Belgian Malinois puppy, bell collar",
        "key": "remove_bg",  # grey bg contrasts the tan dog — ML segmenter isolates cleanly
    },
    "adult": {
        "src": f"{IDEAS}/grok-5050ecbe-8038-434d-9aeb-bfa65c60f341.jpg",
        "box": (1278, 218, 1712, 700),  # full rightmost "Right" adult panel (east-facing); label dropped by _largest_blob
        "description": "adult Belgian Malinois, bell collar",
        "key": "white",  # near-white bg; ML segmenter dropped the low-contrast tan body
    },
}
# established-Briar STYLE reference (carries the existing pixel rendering style;
# the concept image carries the design) — same cell the v2 briar variants use.
STYLE_SRC = "assets/reference/companion_briar_sheet_clean.png"


def _state() -> dict:
    return json.loads(STATE.read_text()) if STATE.exists() else {}


def _save_state(d: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(d, indent=1))


def _b64_path(p: Path) -> dict:
    return {"type": "base64", "base64": base64.b64encode(p.read_bytes()).decode()}


def _white_key(img: Image.Image, thresh: int = 222) -> Image.Image:
    """Drop a flat bright near-grey/white background (deterministic). Keeps the
    tan dog whole where PixelLab's ML segmenter dropped its low-contrast body."""
    import numpy as np
    arr = np.asarray(img.convert("RGBA")).copy()
    rgb = arr[:, :, :3].astype(int)
    mn = rgb.min(axis=2)
    spread = rgb.max(axis=2) - mn
    arr[(mn > thresh) & (spread < 18), 3] = 0  # bright AND near-neutral = background
    return Image.fromarray(arr, "RGBA")


def make_concept(name: str, cfg: dict) -> Path:
    """Side-view panel -> background key -> largest blob -> 512px RGBA concept.
    Mirrors pixellab_v2.make_concept; keying method per variation (see VARIATIONS)."""
    vdir = OUT / name
    vdir.mkdir(parents=True, exist_ok=True)
    crop = Image.open(cfg["src"]).convert("RGB").crop(cfg["box"])
    if cfg["key"] == "white":
        keyed = _white_key(crop)
    else:  # remove_bg — PixelLab's ML background remover (non-checkerboard panels)
        tmp = vdir / "_concept_crop.png"
        crop.resize((400, 400), Image.LANCZOS).save(tmp)
        result = v2.call("remove-background", {
            "image": _b64_path(tmp),
            "image_size": {"width": 400, "height": 400},
        })
        img = result.get("image") or (result.get("images") or [{}])[0]
        keyed = Image.open(io.BytesIO(base64.b64decode(
            img["base64"] if isinstance(img, dict) else img))).convert("RGBA")
    keyed = v2._largest_blob(keyed)  # drop stray label/divider marks
    bbox = keyed.getchannel("A").getbbox()
    if bbox:
        keyed = keyed.crop(bbox)
    side = max(keyed.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(keyed, ((side - keyed.width) // 2, (side - keyed.height) // 2))
    out = vdir / "_concept.png"
    padded.resize((512, 512), Image.LANCZOS).save(out)
    return out


def make_style_ref() -> Path:
    """established Briar cell (0,0) -> clean 32 -> 4x nearest = 128px style ref.
    Mirrors pixellab_v2.make_style_ref('briar')."""
    OUT.mkdir(parents=True, exist_ok=True)
    c = v2.STYLE_CELL_SIZE
    cell = Image.open(STYLE_SRC).crop((0, 0, c, c))
    cell = v2._despill_magenta(cell)
    bbox = cell.getchannel("A").getbbox()
    if bbox:
        cell = cell.crop(bbox)
    side = max(cell.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(cell, ((side - cell.width) // 2, (side - cell.height) // 2))
    out = OUT / "_briar_style_ref.png"
    padded.resize((32, 32), Image.BOX).resize((128, 128), Image.NEAREST).save(out)
    return out


def _payload(name: str, cfg: dict, concept: Path, style: Path) -> dict:
    return {
        "description": cfg["description"],
        "image_size": {"width": SIZE, "height": SIZE},
        "method": "create_from_concept",
        "view": CANON_VIEW,  # low top-down — Projection Canon (Rule 5); never overridden
        "template_id": "dog",
        "concept_image": _b64_path(concept),
        "reference_image": _b64_path(style),
        "no_background": True,
        "style_description": "single isolated character sprite, fully transparent "
        "empty background, no backdrop, no ground tile, no box, no kennel, no "
        "frame, no platform, nothing behind the character",
    }


def create() -> None:
    st = _state()
    style = make_style_ref()
    for name, cfg in VARIATIONS.items():
        if st.get(name, {}).get("character_id"):
            print(f"skip {name} (already created: {st[name]['character_id']})")
            continue
        concept = make_concept(name, cfg)
        payload = _payload(name, cfg, concept, style)
        result = v2.call("create-character-pro", payload)
        st[name] = {
            "character_id": result.get("character_id"),
            "create_job": result.get("background_job_id"),
            "description": cfg["description"],
        }
        # reproducibility log: exact payload minus the giant base64 blobs
        log = {k: v for k, v in payload.items() if not k.endswith("_image")}
        log["concept_image"] = str(concept)
        log["reference_image"] = str(style)
        log["character_id"] = st[name]["character_id"]
        log["endpoint"] = "POST https://api.pixellab.ai/v2/create-character-pro"
        (OUT / name / "params.txt").write_text(json.dumps(log, indent=2) + "\n")
        print(f"{name}: character {st[name]['character_id']} (job {st[name]['create_job']})")
        _save_state(st)
    print("balance:", v2.call("balance", method="GET"))


def _fetch(url: str) -> Image.Image:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=120) as resp:
        return Image.open(io.BytesIO(resp.read())).convert("RGBA")


def _fetch_retry(url: str, tries: int = 16, delay: int = 15) -> Image.Image | None:
    """rotation_urls are pre-allocated before the image file materializes — the
    CDN 403/404s during that lag. Retry until it lands (or give up)."""
    for _ in range(tries):
        try:
            return _fetch(url)
        except urllib.error.HTTPError as e:
            if e.code in (403, 404):
                time.sleep(delay)
                continue
            raise
    return None


def fetch() -> None:
    st = _state()
    for name in VARIATIONS:
        cid = st.get(name, {}).get("character_id")
        if not cid:
            print(f"{name}: not created yet")
            continue
        # 1) wait for the create job (it GENERATES the base rotations; the URLs are
        # listed instantly but the image files only exist once the job completes).
        job = st[name].get("create_job")
        status = "completed"
        for _ in range(80):
            if not job:
                break
            status = v2.call(f"background-jobs/{job}", method="GET").get("status")
            if status in ("completed", "failed", "error", "cancelled"):
                break
            print(f"{name}: create job {status}…")
            time.sleep(15)
        if status not in ("completed", None):
            print(f"{name}: create job ended '{status}'")
        # 2) download the 8 rotations, retrying each through the CDN-materialize lag.
        info = v2.call(f"characters/{cid}", method="GET")
        rot = info.get("rotation_urls") or {}
        vdir = OUT / name
        for i, d in enumerate(DIRECTIONS):
            if d not in rot:
                continue
            img = _fetch_retry(rot[d])
            if img is None:
                print(f"{name}: {d} still unavailable after retries")
                continue
            img.save(vdir / f"{i}_{d}.png")
        # contact strip (3x nearest) for eyeballing
        frames = [Image.open(vdir / f"{i}_{d}.png") for i, d in enumerate(DIRECTIONS)
                  if (vdir / f"{i}_{d}.png").exists()]
        if frames:
            w = max(f.width for f in frames)
            h = max(f.height for f in frames)
            strip = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
            for j, f in enumerate(frames):
                strip.paste(f, (j * w, 0), f)
            strip.resize((strip.width * 3, strip.height * 3), Image.NEAREST).save(
                vdir / "_preview.png")
        print(f"{name}: saved {len(frames)}/8 directions to {vdir} (frame {frames[0].size if frames else '?'})")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["create", "fetch"])
    args = ap.parse_args()
    {"create": create, "fetch": fetch}[args.cmd]()


if __name__ == "__main__":
    main()
