#!/usr/bin/env python3
"""PixelLab terrain tilesets for the zone art pass (2026-06-11 + redesign 2026-07-26).

Wang transition tilesets via POST /create-tileset (async), 32px tiles.
The color_image keeps the generated palettes anchored to the existing
flat-tile colors so the DuskTint/dread look survives the upgrade.

Canon for NEW queues (2026-07-26 redesign):
  - view ALWAYS "low top-down" (API default is high top-down — that was a bug)
  - transition_size 0.0 or 0.25 for flush ground paths (0.5 reads as elevation)

Usage:
  python3 tools/pixellab_tilesets.py queue --only playground_v2
  python3 tools/pixellab_tilesets.py queue --only playground_v2 --force
  python3 tools/pixellab_tilesets.py status
  python3 tools/pixellab_tilesets.py download --only playground_v2
  python3 tools/pixellab_tilesets.py seam-check --only playground_v2
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

OUT = Path("assets/reference/pixellab_tilesets")
STATE_PATH = OUT / "state.json"
TILE = 32
CANON_VIEW = "low top-down"
# Flush ground: avoid 0.5 (taught raised-path / curb look). 0.0 = sharp dual-terrain.
DEFAULT_TRANSITION = 0.0

# palette anchors from gen_ground_tiles.py (warm grass, path, cold grass, floor, sand)
PALETTE = [(96, 102, 58), (84, 90, 50), (150, 128, 88), (138, 117, 79),
           (58, 74, 56), (50, 65, 49), (52, 44, 36), (45, 38, 31),
           (178, 160, 118), (166, 149, 109)]

# Descriptions only; view / transition_size applied in queue() from defaults or per-set keys.
TILESETS = {
    # --- legacy names (kept so old state.json + atlases still resolve) ---
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
    "grass_blend": {
        "lower_description": "dry village grass at dusk, muted warm green with golden evening light, sparse blades",
        "upper_description": "cold wild grass in deep dusk shadow, desaturated blue-green, uneasy mood",
        "transition_description": "healthy dusk grass sickening into cold shadowed grass",
    },
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
    # --- 2026-07-26 redesign (T2): flat, low top-down, flush path ---
    "playground_v2": {
        "lower_description": (
            "flat top-down pixel grass texture only, dry village playground lawn at warm dusk, "
            "muted olive-green short blades, even density, no flowers no rocks no props, "
            "anonymous seamless ground fill, soft golden evening light, completely level surface"
        ),
        "upper_description": (
            "flat top-down packed earth path texture only, trampled dusty tan-brown dirt "
            "flush with surrounding grass height, faint scuffs not footprints, no curb no stones "
            "no elevation no shadow under path, level worn trail"
        ),
        "transition_description": (
            "grass blades thinning into packed dirt on a completely flat plane, soft worn edge, "
            "path and grass same height, no cliff no step no raised border"
        ),
        "transition_size": 0.0,
        "view": CANON_VIEW,
    },
    "ritual_v2": {
        "lower_description": (
            "flat top-down pixel grass texture only, dry village playground lawn at warm dusk, "
            "muted olive-green short blades, even density, no props, seamless anonymous fill"
        ),
        "upper_description": (
            "flat top-down pale ritual sand texture only, fine smoothed sand slightly cool, "
            "faint raked arcs, completely level with grass, no raised ring wall, no props"
        ),
        "transition_description": (
            "grass giving way to pale sand on a flat plane, soft intentional edge, same height, no curb"
        ),
        "transition_size": 0.0,
        "view": CANON_VIEW,
    },
    "grass_blend_v2": {
        "lower_description": (
            "flat top-down warm dusk village grass, muted olive, even short blades, seamless fill"
        ),
        "upper_description": (
            "flat top-down cold wild fringe grass, desaturated blue-green, same height as warm grass, "
            "uneasy dusk shadow, seamless fill no props"
        ),
        "transition_description": (
            "warm grass sickening into cold grass on a flat plane, soft color blend, no elevation"
        ),
        "transition_size": 0.25,
        "view": CANON_VIEW,
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


def _payload_for(cfg: dict, palette: dict) -> dict:
    """Build create-tileset body. Strips tool-local keys (_ref, view/transition overrides)."""
    skip = {"lower_ref", "upper_ref", "transition_size", "view"}
    payload = {k: v for k, v in cfg.items() if k not in skip and not k.endswith("_ref")}
    if "lower_ref" in cfg:
        payload["lower_reference_image"] = tile_ref_b64(cfg["lower_ref"])
    if "upper_ref" in cfg:
        payload["upper_reference_image"] = tile_ref_b64(cfg["upper_ref"])
    payload["tile_size"] = {"width": TILE, "height": TILE}
    payload["transition_size"] = float(cfg.get("transition_size", DEFAULT_TRANSITION))
    payload["view"] = cfg.get("view", CANON_VIEW)
    payload["color_image"] = palette
    return payload


def queue(only: str | None = None, force: bool = False) -> None:
    st = state()
    palette = color_image_b64()
    for name, cfg in TILESETS.items():
        if only and name != only:
            continue
        if st.get(name, {}).get("tileset_id") and not force:
            print(f"skip {name} (queued: {st[name]['tileset_id']}; use --force to re-queue)")
            continue
        payload = _payload_for(cfg, palette)
        print(f"queue {name}: view={payload['view']} transition_size={payload['transition_size']}")
        result = call("create-tileset", payload)
        st[name] = {
            "tileset_id": result.get("tileset_id") or result.get("id"),
            "view": payload["view"],
            "transition_size": payload["transition_size"],
            "raw": {k: v for k, v in result.items() if k != "image"},
        }
        print(f"{name}: {st[name]['tileset_id']}")
        save_state(st)
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def status(only: str | None = None) -> None:
    for name, info in state().items():
        if only and name != only:
            continue
        tid = info.get("tileset_id")
        if not tid:
            print(name, "no tileset_id")
            continue
        try:
            ts = call(f"tilesets/{tid}", method="GET")
        except RuntimeError as e:
            print(name, "error", str(e)[:160])
            continue
        print(name, ts.get("status"), {
            k: v for k, v in ts.items() if k in ("progress", "error", "created_at")
        }, f"view={info.get('view')} ts={info.get('transition_size')}")


def _corner_index(corners: dict) -> int:
    """Stable atlas slot per corner combo: NW NE SW SE bits (upper=1) -> 0..15."""
    bit = {"lower": 0, "upper": 1}
    return (bit[corners["NW"]] << 3) | (bit[corners["NE"]] << 2) \
        | (bit[corners["SW"]] << 1) | bit[corners["SE"]]


def download(only: str | None = None) -> None:
    """GET 200 = ready (16 wang tiles w/ per-corner terrain); 423 = rendering.
    Assembles a 4x4 atlas ordered by corner bitmask + sidecar corner map."""
    st = state()
    for name, info in st.items():
        if only and name != only:
            continue
        try:
            ts = call(f"tilesets/{info['tileset_id']}", method="GET")
        except RuntimeError as e:
            print(f"{name}: not ready ({str(e)[:120]})")
            continue
        tileset = ts.get("tileset") or {}
        tiles = tileset.get("tiles")
        if not tiles:
            print(f"{name}: status={ts.get('status')} (no tiles yet)")
            continue
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


def seam_check(only: str | None = None) -> None:
    """2×2 repeat of pure lower (slot 0) and pure upper (slot 15) for seam QA."""
    names = [only] if only else list(TILESETS)
    for name in names:
        path = OUT / f"{name}_tileset_{TILE}.png"
        if not path.exists():
            print(f"{name}: missing {path}")
            continue
        atlas = Image.open(path).convert("RGBA")
        pure_lower = atlas.crop((0, 0, TILE, TILE))  # corners all lower → index 0
        pure_upper = atlas.crop((3 * TILE, 3 * TILE, 4 * TILE, 4 * TILE))  # all upper → 15
        for label, tile in (("lower", pure_lower), ("upper", pure_upper)):
            sheet = Image.new("RGBA", (TILE * 2, TILE * 2))
            for y in range(2):
                for x in range(2):
                    sheet.paste(tile, (x * TILE, y * TILE))
            out = OUT / f"{name}_seam_{label}_2x2.png"
            sheet.save(out)
            sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(
                OUT / f"{name}_seam_{label}_2x2_x4.png")
            print(f"{name} {label}: {out}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["queue", "status", "download", "seam-check", "list"])
    ap.add_argument("--only")
    ap.add_argument("--force", action="store_true", help="re-queue even if state has an id")
    args = ap.parse_args()
    if args.cmd == "list":
        for name, cfg in TILESETS.items():
            print(f"{name}: view={cfg.get('view', CANON_VIEW)} "
                  f"transition={cfg.get('transition_size', DEFAULT_TRANSITION)}")
    elif args.cmd == "queue":
        queue(args.only, force=args.force)
    elif args.cmd == "status":
        status(args.only)
    elif args.cmd == "download":
        download(args.only)
    else:
        seam_check(args.only)


if __name__ == "__main__":
    main()
