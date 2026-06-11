#!/usr/bin/env python3
"""PixelLab terrain tilesets for the zone art pass (2026-06-11).

Wang transition tilesets via POST /create-tileset (async), 32px tiles.
The color_image keeps the generated palettes anchored to the existing
flat-tile colors so the DuskTint/dread look survives the upgrade.

Usage:
  python3 tools/pixellab_tilesets.py queue     # queue all tilesets
  python3 tools/pixellab_tilesets.py status    # poll
  python3 tools/pixellab_tilesets.py download  # fetch PNGs + previews
"""
import argparse
import base64
import io
import json
import sys
import urllib.request
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402

OUT = Path("assets/reference/pixellab_tilesets")
STATE_PATH = OUT / "state.json"
TILE = 32

# palette anchors from gen_ground_tiles.py (warm grass, path, cold grass, floor, sand)
PALETTE = [(96, 102, 58), (84, 90, 50), (150, 128, 88), (138, 117, 79),
           (58, 74, 56), (50, 65, 49), (52, 44, 36), (45, 38, 31),
           (178, 160, 118), (166, 149, 109)]

TILESETS = {
    "playground": {
        "lower_description": "dry village grass at dusk, muted warm green with golden evening light, sparse blades",
        "upper_description": "trampled packed-earth path, dusty tan-brown dirt, faint footprints",
        "transition_description": "worn grass edge thinning into packed dirt",
    },
    "fringes": {
        "lower_description": "cold wild grass in deep dusk shadow, desaturated blue-green, uneasy mood",
        "upper_description": "dead ashen forest floor, dark soil with grey leaf litter and thin roots",
        "transition_description": "sickly thinning grass fading into dead ground",
    },
    "ritual": {
        "lower_description": "dry village grass at dusk, muted warm green with golden evening light, sparse blades",
        "upper_description": "pale ritual sand circle, fine smoothed sand with faint raked lines, slightly unsettling",
        "transition_description": "grass giving way to a deliberate ring of pale sand",
    },
    # warm->cold transition so the fringe seam is a real Wang boundary.
    # NOTE: lower/upper_reference_image consistently 500s server-side
    # (2026-06-11) — palette continuity rides on color_image alone; residual
    # hue seams are an Aseprite post-pass (R4) if they show in game.
    "grass_blend": {
        "lower_description": "dry village grass at dusk, muted warm green with golden evening light, sparse blades",
        "upper_description": "cold wild grass in deep dusk shadow, desaturated blue-green, uneasy mood",
        "transition_description": "healthy dusk grass sickening into cold shadowed grass",
    },
    # village zone (village-life.md, mood anchor village_dusk_mood.png)
    # reroll note (playtest 2026-06-11): v1's edge stones read as a raised
    # curb — the path looked elevated. Flush wording fixes it.
    "village_green": {
        "lower_description": "village green lawn grass at golden sunset, warm and tended, short blades",
        "upper_description": "old worn cobblestone path laid completely flat and flush with the ground, small rounded stones seen from directly above, no curb, no raised border, no wall",
        "transition_description": "grass blades growing over and between the outermost flat stones, path perfectly level with the lawn, soft seamless edge",
    },
    "village_yard": {
        "lower_description": "village green lawn grass at golden sunset, warm and tended, short blades",
        "upper_description": "packed dirt yard, swept dry earth with faint broom marks",
        "transition_description": "grass thinning into trodden bare earth",
    },
}


def state() -> dict:
    return json.loads(STATE_PATH.read_text()) if STATE_PATH.exists() else {}


def save_state(data: dict) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(data, indent=1))


def color_image_b64() -> dict:
    # reference images must be exactly 64x64 (API constraint)
    img = Image.new("RGB", (64, 64))
    stripe = 64 // len(PALETTE)
    for i, color in enumerate(PALETTE):
        for x in range(i * stripe, 64 if i == len(PALETTE) - 1 else (i + 1) * stripe):
            for y in range(64):
                img.putpixel((x, y), color)
    buf = io.BytesIO()
    img.save(buf, "PNG")
    return {"type": "base64", "base64": base64.b64encode(buf.getvalue()).decode()}


def tile_ref_b64(spec: str) -> dict:
    """'atlas.png:<slot>' -> that 32px tile NEAREST-upscaled to the required 64x64."""
    fname, idx = spec.rsplit(":", 1)
    i = int(idx)
    atlas = Image.open(OUT / fname)
    tile = atlas.crop(((i % 4) * TILE, (i // 4) * TILE, (i % 4 + 1) * TILE, (i // 4 + 1) * TILE))
    buf = io.BytesIO()
    tile.resize((64, 64), Image.NEAREST).save(buf, "PNG")
    return {"type": "base64", "base64": base64.b64encode(buf.getvalue()).decode()}


def queue(only: str | None = None) -> None:
    st = state()
    palette = color_image_b64()
    for name, cfg in TILESETS.items():
        if only and name != only:
            continue
        if st.get(name, {}).get("tileset_id"):
            print(f"skip {name} (queued: {st[name]['tileset_id']})")
            continue
        payload = {k: v for k, v in cfg.items() if not k.endswith("_ref")}
        if "lower_ref" in cfg:
            payload["lower_reference_image"] = tile_ref_b64(cfg["lower_ref"])
        if "upper_ref" in cfg:
            payload["upper_reference_image"] = tile_ref_b64(cfg["upper_ref"])
        result = call("create-tileset", {
            **payload,
            "tile_size": {"width": TILE, "height": TILE},
            "transition_size": 0.5,
            "color_image": palette,
        })
        st[name] = {"tileset_id": result.get("tileset_id") or result.get("id"),
                    "raw": {k: v for k, v in result.items() if k != "image"}}
        print(f"{name}: {st[name]['tileset_id']}")
        save_state(st)
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def status() -> None:
    for name, info in state().items():
        ts = call(f"tilesets/{info['tileset_id']}", method="GET")
        print(name, ts.get("status"), {k: v for k, v in ts.items()
              if k in ("progress", "error", "created_at")})


def _corner_index(corners: dict) -> int:
    """Stable atlas slot per corner combo: NW NE SW SE bits (upper=1) -> 0..15."""
    bit = {"lower": 0, "upper": 1}
    return (bit[corners["NW"]] << 3) | (bit[corners["NE"]] << 2) \
        | (bit[corners["SW"]] << 1) | bit[corners["SE"]]


def download() -> None:
    """GET 200 = ready (16 wang tiles w/ per-corner terrain); 423 = rendering.
    Assembles a 4x4 atlas ordered by corner bitmask + sidecar corner map."""
    st = state()
    for name, info in st.items():
        try:
            ts = call(f"tilesets/{info['tileset_id']}", method="GET")
        except RuntimeError as e:
            print(f"{name}: not ready ({str(e)[:120]})")
            continue
        tiles = ts["tileset"]["tiles"]
        atlas = Image.new("RGBA", (4 * TILE, 4 * TILE), (0, 0, 0, 0))
        corner_map = {}
        for tile_entry in tiles:
            idx = _corner_index(tile_entry["corners"])
            img = Image.open(io.BytesIO(base64.b64decode(tile_entry["image"]["base64"])))
            atlas.paste(img.convert("RGBA"), ((idx % 4) * TILE, (idx // 4) * TILE))
            corner_map[str(idx)] = tile_entry["corners"]
        OUT.mkdir(parents=True, exist_ok=True)
        path = OUT / f"{name}_tileset_{TILE}.png"
        atlas.save(path)
        (OUT / f"{name}_corners.json").write_text(json.dumps(corner_map, indent=1))
        atlas.resize((atlas.width * 4, atlas.height * 4), Image.NEAREST).save(
            OUT / f"{name}_tileset_preview.png")
        print(f"{name}: {path} ({len(tiles)} tiles)")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["queue", "status", "download"])
    ap.add_argument("--only")
    args = ap.parse_args()
    if args.cmd == "queue":
        queue(args.only)
    elif args.cmd == "status":
        status()
    else:
        download()


if __name__ == "__main__":
    main()
