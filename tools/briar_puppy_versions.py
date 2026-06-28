#!/usr/bin/env python3
"""Briar puppy, two style versions -> 4-direction sheets + first-pass animations.

Same two Grok references as before, but treated as the SAME normal puppy in two
LOOKS (not corrupted, not adult):
  V1 = chunky 4-view sheet (front/left/back/right) -> image-to-pixelart per view
       (preserve the look; only the existing views, no re-rotation).
  V2 = painterly sheet, FRONT panel A only -> concept-to-sprite (create-character-
       pro / create_from_concept), let PixelLab make proper low-top-down rotations.

REUSES tools/pixellab_v2.py (call / keying / blob helpers) + the canon view from
pixellab_api.py. View stays HARDCODED low top-down (Rule 5) — never overridden.
PHASE 2 uses text-to-animate (animate-character mode=v3 action_description) for
DRAFTS only; skeleton rigging + frame polish are a manual editor step, not headless.
Canvas 64 (both refs ~64; PixelLab animation wants 64-128). 4 cardinal directions.

Subcommands: v1-sheet · v2-create · v2-fetch · v1-char · animate · download · verify
"""
import argparse
import base64
import importlib.util
import io
import json
import shutil
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_api import CANON_VIEW  # noqa: E402  (the one Projection-Canon view, Rule 5)
_spec = importlib.util.spec_from_file_location("pixellab_v2", Path(__file__).parent / "pixellab_v2.py")
v2 = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(v2)

OUT = Path("assets/companions/briar")
STATE = OUT / "_puppy_versions_state.json"
SIZE = 64
CARDINAL = ["south", "north", "east", "west"]
IDEAS = "/home/seitanist/Documents/cycle_of_innocence_ideas"
V1_SRC = f"{IDEAS}/grok-5050ecbe-8038-434d-9aeb-bfa65c60f341.jpg"
V2_SRC = f"{IDEAS}/grok-9889dda1-f5c4-4c35-bb97-f8fe7c02c8a7.png"

# V1: the four panels (front/left/back/right -> south/west/north/east). Generous
# boxes; the label under each dog is dropped by _largest_blob.
V1_PANELS = {
    "south": (134, 214, 366, 660),   # front
    "west":  (454, 215, 896, 660),   # left side (facing left)
    "north": (975, 215, 1206, 660),  # back
    "east":  (1275, 215, 1716, 660),  # right side (facing right)
}
V2_PANEL_A = (180, 168, 442, 462)  # painterly FRONT A-pose only (title/labels excluded)
V2_STYLE_SRC = "assets/reference/companion_briar_sheet_clean.png"  # established pixel STYLE

# PHASE 2 first-pass animation drafts (text-to-animate). Set chosen from the goal
# (idle/walk/run/dig/bark) + Briar's implemented tells found in companion_base.gd
# (seek=alert/point 'stare' tell; growl). action_description = v3 text-to-animate.
ANIMS = [
    ("idle", "a small puppy standing still, breathing gently, ears twitching", CARDINAL),
    ("walk", "a small puppy walking at a calm steady pace", CARDINAL),
    ("run", "a small puppy running quickly in an energetic gallop", CARDINAL),
    ("dig", "a small puppy digging energetically in the dirt with its front paws", ["south", "east"]),
    ("bark", "a small puppy barking, head bobbing, front paws braced", ["south", "east"]),
    ("seek", "a small puppy freezing alert, head raised, pointing rigidly at something — an alert point tell", CARDINAL),
    ("growl", "a small puppy growling low, hackles raised, head lowered, body tense", CARDINAL),
]


def _state() -> dict:
    return json.loads(STATE.read_text()) if STATE.exists() else {}


def _save_state(d: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(d, indent=1))


def _b64(p: Path) -> dict:
    return {"type": "base64", "base64": base64.b64encode(p.read_bytes()).decode()}


def _white_key(img: Image.Image, thresh: int = 222) -> Image.Image:
    """Drop a flat bright near-white background deterministically (V1 panels)."""
    import numpy as np
    arr = np.asarray(img.convert("RGBA")).copy()
    rgb = arr[:, :, :3].astype(int)
    mn = rgb.min(axis=2)
    spread = rgb.max(axis=2) - mn
    arr[(mn > thresh) & (spread < 18), 3] = 0
    return Image.fromarray(arr, "RGBA")


def _isolate(keyed: Image.Image) -> Image.Image:
    keyed = v2._largest_blob(keyed)
    bbox = keyed.getchannel("A").getbbox()
    if bbox:
        keyed = keyed.crop(bbox)
    side = max(keyed.size)
    pad = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    pad.paste(keyed, ((side - keyed.width) // 2, (side - keyed.height) // 2))
    return pad


# ---------- PHASE 1 ----------

def v1_sheet() -> None:
    """Each existing V1 view -> clean key + downscale to fit 64 (PRESERVE the chunky
    look). PixelLab's image-to-pixelart degrades these already-pixel-art views
    (verified: it hallucinated a face on the back view), so a direct clean downscale
    is the higher-quality 'edit' path the goal allows when image-to-pixelart can't."""
    sdir = OUT / "puppy_v1" / "sheet"
    sdir.mkdir(parents=True, exist_ok=True)
    for d, box in V1_PANELS.items():
        crop = Image.open(V1_SRC).convert("RGB").crop(box)
        iso = _isolate(_white_key(crop))  # full-res isolated dog, transparent bg
        target = 58  # fit the dog inside 64 with a small margin
        scale = target / max(iso.size)
        small = iso.resize((max(1, round(iso.width * scale)),
                            max(1, round(iso.height * scale))), Image.LANCZOS)
        canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        canvas.paste(small, ((SIZE - small.width) // 2, (SIZE - small.height) // 2), small)
        # crisp the faint AA halo so the background reads as clean transparency
        import numpy as np
        arr = np.asarray(canvas).copy()
        arr[arr[:, :, 3] < 40, 3] = 0
        Image.fromarray(arr, "RGBA").save(sdir / f"{d}.png")
        print(f"v1 {d}: {sdir / f'{d}.png'}")
    _assemble_sheet("puppy_v1")


def v2_create() -> None:
    """Panel A front -> concept -> create-character-pro (concept-to-sprite)."""
    st = _state()
    vdir = OUT / "puppy_v2"
    vdir.mkdir(parents=True, exist_ok=True)
    crop = Image.open(V2_SRC).convert("RGB").crop(V2_PANEL_A)
    tmp = vdir / "_panelA_crop.png"
    crop.resize((400, 400), Image.LANCZOS).save(tmp)
    res = v2.call("remove-background", {"image": _b64(tmp), "image_size": {"width": 400, "height": 400}})
    img = res.get("image") or (res.get("images") or [{}])[0]
    keyed = Image.open(io.BytesIO(base64.b64decode(
        img["base64"] if isinstance(img, dict) else img))).convert("RGBA")
    concept = _isolate(keyed)
    concept_path = vdir / "_concept.png"
    concept.resize((512, 512), Image.LANCZOS).save(concept_path)
    style = _v2_style_ref()
    payload = {
        "description": "small Belgian Malinois puppy, fawn-tan coat, black mask, "
        "large upright ears, small bell on a collar",
        "image_size": {"width": SIZE, "height": SIZE},
        "method": "create_from_concept",
        "view": CANON_VIEW,  # low top-down — Rule 5, never overridden
        "template_id": "dog",
        "concept_image": _b64(concept_path),
        "reference_image": _b64(style),
        "no_background": True,
        "style_description": "single isolated character sprite, fully transparent "
        "empty background, no backdrop, no ground tile, no box, no frame, no platform",
    }
    result = v2.call("create-character-pro", payload)
    st["v2"] = {"character_id": result.get("character_id"), "create_job": result.get("background_job_id")}
    _save_state(st)
    log = {k: v for k, v in payload.items() if not k.endswith("_image")}
    log.update(concept_image=str(concept_path), reference_image=str(style),
               character_id=st["v2"]["character_id"],
               endpoint="POST https://api.pixellab.ai/v2/create-character-pro")
    (OUT / "puppy_v2" / "params.txt").write_text(json.dumps(log, indent=2) + "\n")
    print(f"v2: character {st['v2']['character_id']} (job {st['v2']['create_job']})")


def _v2_style_ref() -> Path:
    c = v2.STYLE_CELL_SIZE
    cell = v2._despill_magenta(Image.open(V2_STYLE_SRC).crop((0, 0, c, c)))
    bbox = cell.getchannel("A").getbbox()
    if bbox:
        cell = cell.crop(bbox)
    side = max(cell.size)
    pad = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    pad.paste(cell, ((side - cell.width) // 2, (side - cell.height) // 2))
    out = OUT / "puppy_v2" / "_style_ref.png"
    pad.resize((32, 32), Image.BOX).resize((128, 128), Image.NEAREST).save(out)
    return out


def _fetch_retry(url: str, tries: int = 16, delay: int = 15) -> Image.Image | None:
    for _ in range(tries):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=120) as resp:
                return Image.open(io.BytesIO(resp.read())).convert("RGBA")
        except urllib.error.HTTPError as e:
            if e.code in (403, 404):
                time.sleep(delay)
                continue
            raise
    return None


def _wait_job(job: str, label: str) -> str:
    status = "completed"
    for _ in range(80):
        if not job:
            break
        status = v2.call(f"background-jobs/{job}", method="GET").get("status")
        if status in ("completed", "failed", "error", "cancelled"):
            break
        print(f"{label}: create job {status}…")
        time.sleep(15)
    return status


def v2_fetch() -> None:
    """Pull V2's 4 cardinal rotations into the sheet."""
    st = _state()
    cid = st["v2"]["character_id"]
    _wait_job(st["v2"].get("create_job"), "v2")
    info = v2.call(f"characters/{cid}", method="GET")
    rot = info.get("rotation_urls") or {}
    sdir = OUT / "puppy_v2" / "sheet"
    sdir.mkdir(parents=True, exist_ok=True)
    for d in CARDINAL:
        if d not in rot:
            print(f"v2 {d}: MISSING rotation")
            continue
        img = _fetch_retry(rot[d])
        if img is None:
            print(f"v2 {d}: unavailable after retries")
            continue
        img.save(sdir / f"{d}.png")
        print(f"v2 {d}: {sdir / f'{d}.png'} {img.size}")
    _assemble_sheet("puppy_v2")


def v1_char() -> None:
    """Animation character for V1. NOTE: create-character-with-4-directions hangs
    (>300s SSL timeout), so we use the proven fast create-character-pro path —
    concept = V1's FRONT panel, style = V1's own south sprite (carries the chunky
    look). The V1 SHEET already preserves the original 4 views; this character only
    drives the first-pass animation drafts."""
    st = _state()
    vdir = OUT / "puppy_v1"
    crop = Image.open(V1_SRC).convert("RGB").crop(V1_PANELS["south"])
    concept = _isolate(_white_key(crop))
    cpath = vdir / "_concept.png"
    concept.resize((512, 512), Image.LANCZOS).save(cpath)
    spath = vdir / "_style_ref.png"
    Image.open(OUT / "puppy_v1" / "sheet" / "south.png").convert("RGBA").resize(
        (128, 128), Image.NEAREST).save(spath)
    payload = {
        "description": "small chunky Belgian Malinois puppy, fawn-tan coat, black "
        "mask, large upright ears, small bell on a collar",
        "image_size": {"width": SIZE, "height": SIZE},
        "method": "create_from_concept",
        "view": CANON_VIEW,  # low top-down — Rule 5, never overridden
        "template_id": "dog",
        "concept_image": _b64(cpath),
        "reference_image": _b64(spath),
        "no_background": True,
        "style_description": "single isolated character sprite, fully transparent "
        "empty background, no backdrop, no ground tile, no box, no frame, no platform",
    }
    result = v2.call("create-character-pro", payload)
    st["v1"] = {"character_id": result.get("character_id"), "create_job": result.get("background_job_id")}
    _save_state(st)
    log = {k: v for k, v in payload.items() if not k.endswith("_image")}
    log.update(concept_image=str(cpath), reference_image=str(spath),
               character_id=st["v1"]["character_id"],
               sheet_method="image-to-pixelart degraded the source; sheet uses clean key+downscale of the 4 original views",
               anim_character_method="create-character-pro create_from_concept (create-character-with-4-directions hung)",
               endpoint="POST https://api.pixellab.ai/v2/create-character-pro")
    (OUT / "puppy_v1" / "params.txt").write_text(json.dumps(log, indent=2) + "\n")
    print(f"v1: character {st['v1']['character_id']} (job {st['v1']['create_job']})")


def _assemble_sheet(ver: str) -> None:
    sdir = OUT / ver / "sheet"
    frames = [(d, Image.open(sdir / f"{d}.png").convert("RGBA")) for d in CARDINAL
              if (sdir / f"{d}.png").exists()]
    if not frames:
        return
    w = max(f.width for _, f in frames)
    h = max(f.height for _, f in frames)
    sheet = Image.new("RGBA", (w * len(frames), h), (0, 0, 0, 0))
    for i, (_d, f) in enumerate(frames):
        sheet.paste(f, (i * w + (w - f.width) // 2, (h - f.height) // 2), f)
    sheet.save(sdir / "_sheet_4dir.png")
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(sdir / "_sheet_4dir_preview.png")


# ---------- PHASE 2 ----------

def animate(only: str | None = None) -> None:
    st = _state()
    for ver in ("v1", "v2"):
        if only and ver != only:
            continue
        cid = st.get(ver, {}).get("character_id")
        if not cid:
            print(f"{ver}: no character")
            continue
        _wait_job(st[ver].get("create_job"), ver)  # animate only once rotations exist
        st[ver].setdefault("anim", {})
        for name, action, dirs in ANIMS:
            for i in range(0, len(dirs), 4):
                chunk = dirs[i:i + 4]
                key = f"{name}_{'_'.join(chunk)}"
                if st[ver]["anim"].get(key):
                    print(f"{ver}/{key}: queued already")
                    continue
                payload = {"character_id": cid, "animation_name": name,
                           "directions": chunk, "mode": "v3",
                           "action_description": action, "frame_count": 4}
                for attempt in range(30):
                    try:
                        v2.call("animate-character", payload)
                        st[ver]["anim"][key] = "queued"
                        _save_state(st)
                        print(f"{ver}/{key}: queued")
                        break
                    except RuntimeError as e:
                        msg = str(e)
                        if "429" in msg:
                            time.sleep(75)
                            continue
                        if any(f"{c} on animate" in msg for c in (404, 500, 502, 503)):
                            print(f"{ver}/{key}: transient {msg[:48]}… retry")
                            time.sleep(12)
                            continue
                        print(f"{ver}/{key}: FAILED {msg[:80]}")
                        break
    print("balance:", v2.call("balance", method="GET"))


def download(only: str | None = None) -> None:
    """Pull animation frames per (name, direction) from the character API's frame
    URLs (fetchable with a browser UA). Avoids the ZIP export, which 423-Locks while
    the character is still generating. Saves whatever is ready (drafts may be partial)."""
    st = _state()
    for ver in ("v1", "v2"):
        if only and ver != only:
            continue
        cid = st.get(ver, {}).get("character_id")
        if not cid:
            continue
        keys = st[ver].get("anim", {})
        expected = sum(max(0, len(k.split("_")) - 1) for k in keys)  # total (anim,dir) pairs queued
        info: dict = {}
        for _ in range(70):
            info = v2.call(f"characters/{cid}", method="GET")
            pairs = [1 for a in info.get("animations", [])
                     for d in a.get("directions", []) if d.get("frames")]
            print(f"{ver}: {len(pairs)}/{expected} animation-directions ready "
                  f"({len(info.get('animations', []))} groups)")
            if expected and len(pairs) >= expected:
                break
            time.sleep(20)
        saved = _save_anim_urls(ver, info)
        print(f"{ver}: saved {saved} frames into {OUT / ver / 'anim'}")


def _save_anim_urls(ver: str, info: dict) -> int:
    saved = 0
    for a in info.get("animations", []):
        name = (a.get("display_name") or a.get("animation_type") or "anim").lower()
        name = name.replace(" ", "_").replace("-", "_")
        for d in a.get("directions", []):
            urls = d.get("frames", [])
            if not urls:
                continue
            dst = OUT / f"puppy_{ver}" / "anim" / name / d["direction"]
            dst.mkdir(parents=True, exist_ok=True)
            for i, u in enumerate(urls):
                url = u if isinstance(u, str) else (u.get("url") or u.get("base64", ""))
                img = _fetch_retry(url)
                if img is not None:
                    img.save(dst / f"frame_{i:02d}.png")
                    saved += 1
    return saved


# ---------- verify ----------

def verify() -> None:
    import numpy as np
    ok = True
    for ver in ("puppy_v1", "puppy_v2"):
        print(f"\n=== {ver} ===")
        for p in sorted((OUT / ver).rglob("*.png")):
            if p.name.startswith("_"):
                continue
            a = np.asarray(Image.open(p).convert("RGBA"))[:, :, 3]
            tb = bool(a[0, 0] == 0 and a[0, -1] == 0 and a[-1, 0] == 0 and a[-1, -1] == 0)
            rng = bool(a.min() == 0 and a.max() == 255)
            if not (tb and rng):
                ok = False
            print(f"  {p.relative_to(OUT / ver)}: {Image.open(p).size} bg_transp={tb} alpha0..255={rng}")
    print("\nALL TRANSPARENT" if ok else "\nSOME NON-TRANSPARENT — CHECK")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["v1-sheet", "v2-create", "v2-fetch", "v1-char",
                                    "animate", "download", "verify"])
    ap.add_argument("--only")
    args = ap.parse_args()
    {"v1-sheet": v1_sheet, "v2-create": v2_create, "v2-fetch": v2_fetch,
     "v1-char": v1_char, "animate": lambda: animate(args.only),
     "download": lambda: download(args.only), "verify": verify}[args.cmd]()


if __name__ == "__main__":
    main()
