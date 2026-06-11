#!/usr/bin/env python3
"""Villager NPCs via PixelLab create-character-pro (village-life.md).

Concept = keyed front-view crop from the approved Grok bibles; style
reference = a cell of the LIVE in-game Rowan sheet (PixelLab's own output),
so villagers match what actually renders in the game, not an intermediate.

Usage:
  python3 tools/pixellab_npcs.py create    # queue 4 character creations
  python3 tools/pixellab_npcs.py status    # poll create jobs
  python3 tools/pixellab_npcs.py animate   # queue walk + idle (4-dir each)
  python3 tools/pixellab_npcs.py download  # fetch + unpack ZIPs
  python3 tools/pixellab_npcs.py sheets    # assemble sheets + .tres
"""
import argparse
import importlib.util
import io
import json
import sys
import time
import urllib.request
import zipfile
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call, get_bytes, b64, _largest_blob, PRO_CELL  # noqa: E402

_spec = importlib.util.spec_from_file_location("pixelize", Path(__file__).parent / "pixelize.py")
pixelize = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(pixelize)

OUT = Path("assets/reference/pixellab_npcs")
STATE_PATH = OUT / "state.json"
ROWAN_SHEET = "assets/sprites/player/child_sheet_32.png"
ROWAN_IDLE_ROW = 4  # idle_down row in the live sheet (48px cells)

# name: (bible file, crop as fractions l,t,r,b, description)
NPCS = {
    "villager_parent": (
        "assets/reference/villager_parent_bible.png",
        (0.017, 0.050, 0.233, 0.375),
        "adult village farmer, tired kind face, straw hat, beige work shirt "
        "with rolled sleeves, brown apron with patch pocket, dark trousers, "
        "small red festival rosette ribbon on chest"),
    "villager_warden": (
        "assets/reference/villager_warden_bible.png",
        (0.013, 0.047, 0.253, 0.430),
        "heavyset village warden, long dark oilskin coat, wide-brim dark hat "
        "shadowing the face, carved wooden lantern pole with hanging lantern "
        "and small bell, grimy festival-yellow armband"),
    "villager_elder": (
        "assets/reference/villager_elder_bible.png",
        (0.020, 0.067, 0.242, 0.433),
        "elderly village priest, layered olive and purple wool robes, pale "
        "knitted shawl, round glasses, white hair, wooden shepherd's crook "
        "staff, small stuffed animal charms hanging from his belt"),
    "villager_child": (
        "assets/reference/villager_child_bible.png",
        (0.363, 0.042, 0.633, 0.392),
        "small cheerful village child, brown messy hair with red festival "
        "ribbon, green patched tunic, yellow scarf, orange shorts, brown "
        "boots, holding a small lavender stuffed bunny"),
}

# NPC routines need locomotion + presence only (village-life.md scope)
ANIMATIONS = [
    ("walk", "walk", ["south", "north", "east", "west"]),
    ("idle", "breathing-idle", ["south", "north", "east", "west"]),
]

SHEET_ROWS = [
    ("walk_down", "walk", "south", "loop", 8),
    ("walk_up", "walk", "north", "loop", 8),
    ("walk_right", "walk", "east", "loop", 8),
    ("walk_left", "walk", "west", "loop", 8),
    ("idle_down", "breathing-idle", "south", "loop", 5),
    ("idle_up", "breathing-idle", "north", "loop", 5),
    ("idle_right", "breathing-idle", "east", "loop", 5),
    ("idle_left", "breathing-idle", "west", "loop", 5),
]


def state() -> dict:
    return json.loads(STATE_PATH.read_text()) if STATE_PATH.exists() else {}


def save_state(data: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(data, indent=1))


def make_concept(name: str) -> Path:
    src, frac, _desc = NPCS[name]
    img = Image.open(src)
    box = (int(frac[0] * img.width), int(frac[1] * img.height),
           int(frac[2] * img.width), int(frac[3] * img.height))
    keyed = pixelize.key_background(img.crop(box))
    bbox = keyed.getchannel("A").getbbox()
    if bbox:
        keyed = keyed.crop(bbox)
    keyed = _largest_blob(keyed)
    side = max(keyed.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(keyed, ((side - keyed.width) // 2, (side - keyed.height) // 2))
    OUT.mkdir(parents=True, exist_ok=True)
    out = OUT / f"{name}_concept.png"
    padded.resize((512, 512), Image.LANCZOS).save(out)
    return out


def make_style_ref() -> Path:
    """The live in-game Rowan idle cell — style self-consistency with what
    the game actually renders (user direction 2026-06-11)."""
    sheet = Image.open(ROWAN_SHEET).convert("RGBA")
    cell = sheet.crop((0, ROWAN_IDLE_ROW * PRO_CELL,
                       PRO_CELL, (ROWAN_IDLE_ROW + 1) * PRO_CELL))
    bbox = cell.getchannel("A").getbbox()
    if bbox:
        cell = cell.crop(bbox)
    side = max(cell.size)
    padded = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    padded.paste(cell, ((side - cell.width) // 2, (side - cell.height) // 2))
    OUT.mkdir(parents=True, exist_ok=True)
    out = OUT / "style_ref_rowan_live.png"
    padded.resize((32, 32), Image.BOX).resize((128, 128), Image.NEAREST).save(out)
    return out


def create(only: str | None = None) -> None:
    st = state()
    style = make_style_ref()
    for name, (_src, _frac, desc) in NPCS.items():
        if only and name != only:
            continue
        if st.get(name, {}).get("character_id") or st.get(name, {}).get("create_job"):
            print(f"skip {name} (created/queued)")
            continue
        result = call("create-character-pro", {
            "description": desc,
            "image_size": {"width": 32, "height": 32},
            "method": "create_from_concept",
            "view": "low top-down",
            "template_id": "mannequin",
            "concept_image": b64(make_concept(name)),
            "reference_image": b64(style),
            "no_background": True,
        })
        st[name] = {"create_job": result.get("background_job_id"),
                    "character_id": result.get("character_id")}
        print(f"{name}: character {st[name]['character_id']} (job {st[name]['create_job']})")
        save_state(st)
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def status() -> None:
    st = state()
    for name, info in st.items():
        for key in [k for k in info if k.endswith("_job") or k.startswith("anim_job_")]:
            jid = info[key]
            if not isinstance(jid, str) or len(jid) < 30:
                continue  # not a job id
            job = call(f"background-jobs/{jid}", method="GET")
            print(f"{name}/{key}: {job.get('status')}")
            if job.get("status") == "completed" and key == "create_job":
                last = job.get("last_response") or {}
                cid = last.get("character_id") or last.get("id")
                if cid:
                    info["character_id"] = cid
    save_state(st)


def animate(only: str | None = None) -> None:
    st = state()
    for name in NPCS:
        if only and name != only:
            continue
        cid = st.get(name, {}).get("character_id")
        if not cid:
            print(f"{name}: no character yet")
            continue
        for anim_name, template, directions in ANIMATIONS:
            for chunk_start in range(0, len(directions), 2):
                chunk = directions[chunk_start:chunk_start + 2]
                key = f"anim_job_{anim_name}_{'_'.join(chunk)}"
                if st[name].get(key):
                    print(f"skip {name}/{anim_name} {chunk}")
                    continue
                for _attempt in range(40):
                    try:
                        result = call("animate-character", {
                            "character_id": cid,
                            "animation_name": anim_name,
                            "directions": chunk,
                            "mode": "template",
                            "template_animation_id": template,
                        })
                        jids = result.get("background_job_ids") or []
                        st[name][key] = jids[0] if jids else "queued"
                        print(f"{name}/{anim_name} {chunk}: queued")
                        save_state(st)
                        break
                    except RuntimeError as e:
                        if "429" in str(e):
                            time.sleep(75)
                            continue
                        raise
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def download() -> None:
    st = state()
    for name, info in st.items():
        cid = info.get("character_id")
        if not cid:
            continue
        dest = OUT / "chars" / name
        dest.mkdir(parents=True, exist_ok=True)
        data = get_bytes(f"characters/{cid}/zip")
        with zipfile.ZipFile(io.BytesIO(data)) as zf:
            zf.extractall(dest)
        print(f"{name}: {len(list(dest.rglob('*.png')))} pngs")


def _anim_map(name: str) -> dict:
    """(animation_type, direction) -> frame dir (pixellab_v2.pro_anim_map,
    localized to the npc state/folders)."""
    st = state()
    info = call(f"characters/{st[name]['character_id']}", method="GET")
    anim_root = next((OUT / "chars" / name).glob("*/animations"))
    folders = [f for f in anim_root.iterdir() if f.is_dir()]
    mapping: dict = {}
    for group in info.get("animations") or []:
        gid8 = group["animation_group_id"][:8]
        suffixed = next((f for f in folders if f.name.endswith(gid8)), None)
        for dentry in group.get("directions", []):
            direction = dentry["direction"]
            folder = suffixed
            if folder is None:
                for f in folders:
                    ddir = f / direction
                    if ddir.is_dir() and len(list(ddir.glob("frame_*.png"))) == dentry["frame_count"] \
                            and not any(f.name.endswith(g["animation_group_id"][:8])
                                        for g in info["animations"]):
                        folder = f
                        break
            if folder and (folder / direction).is_dir():
                mapping[(group["animation_type"], direction)] = folder / direction
    return mapping


def sheets(only: str | None = None) -> None:
    sys.path.insert(0, str(Path(__file__).parent))
    from pixellab_v2 import _write_tres
    for name in NPCS:
        if only and name != only:
            continue
        mapping = _anim_map(name)
        rows_frames = []
        max_cols = 0
        missing = []
        for row_name, anim_type, direction, _loop, _fps in SHEET_ROWS:
            frame_dir = mapping.get((anim_type, direction))
            if frame_dir is None:
                missing.append(f"{row_name} ({anim_type}/{direction})")
                continue
            imgs = []
            for fp in sorted(frame_dir.glob("frame_*.png")):
                img = Image.open(fp).convert("RGBA")
                if img.width > PRO_CELL:
                    ox = (img.width - PRO_CELL) // 2
                    oy = (img.height - PRO_CELL) // 2
                    img = img.crop((ox, oy, ox + PRO_CELL, oy + PRO_CELL))
                imgs.append(img)
            max_cols = max(max_cols, len(imgs))
            rows_frames.append((row_name, imgs))
        if missing:
            print(f"{name}: MISSING {missing} — skipping")
            continue
        sheet = Image.new("RGBA", (max_cols * PRO_CELL, len(rows_frames) * PRO_CELL), (0, 0, 0, 0))
        for r, (_n, imgs) in enumerate(rows_frames):
            for c, img in enumerate(imgs):
                sheet.paste(img, (c * PRO_CELL, r * PRO_CELL))
        cfg = {"out": f"assets/sprites/npcs/{name}_32.png",
               "tres": f"assets/resources/npcs/{name}_frames.tres",
               "rows": SHEET_ROWS, "aliases": {}}
        Path(cfg["out"]).parent.mkdir(parents=True, exist_ok=True)
        Path(cfg["tres"]).parent.mkdir(parents=True, exist_ok=True)
        sheet.save(cfg["out"])
        sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST).save(
            cfg["out"].replace(".png", "_preview.png"))
        _write_tres(name, cfg, rows_frames, PRO_CELL)
        print(f"sheet: {cfg['out']} ({len(rows_frames)} rows x {max_cols} cols)")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["create", "status", "animate", "download", "sheets"])
    ap.add_argument("--only")
    args = ap.parse_args()
    {"create": create, "animate": animate, "sheets": sheets,
     "status": lambda only=None: status(),
     "download": lambda only=None: download()}[args.cmd](args.only)


if __name__ == "__main__":
    main()
