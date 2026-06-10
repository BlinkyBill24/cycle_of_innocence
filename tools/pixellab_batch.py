#!/usr/bin/env python3
"""PixelLab character animation batch (docs/decisions/2026-06-10-sprite-tool-pixellab.md).

Per character: a reference crop (from the user-approved bible-derived sheets)
drives animate-with-text calls per animation/direction at 64px. Frames land in
assets/reference/pixellab_batch/ (idempotent: existing frame sets are skipped,
re-runs never double-spend). `assemble` builds 32px game sheets via the
pixelize cell pipeline.

Usage:
  python3 tools/pixellab_batch.py generate [--only rowan|briar|twisted]
  python3 tools/pixellab_batch.py assemble
"""
import argparse
import importlib.util
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_api import call, b64_image  # noqa: E402

_spec = importlib.util.spec_from_file_location("pixelize", Path(__file__).parent / "pixelize.py")
pixelize = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(pixelize)

OUT = Path("assets/reference/pixellab_batch")
VIEW = "low top-down"

# (anim_name, action_text, direction)
CHARACTERS = {
    "rowan": {
        "ref_sheet": "assets/reference/protagonist_child_sheet_clean.png",
        "ref_cell": (0, 4, 296),  # col, row, cell_px  (idle front)
        "description": "small 9 year old village child, messy dark purple-brown hair, pale, big sad eyes, grey rough-spun knee-length tunic with faded red hand print on chest, bare feet, pixel art",
        "anims": [
            ("walk_down", "walking", "south"),
            ("walk_up", "walking", "north"),
            ("walk_right", "walking", "east"),
            ("idle_down", "standing still, breathing, slight sway", "south"),
            ("attack", "swinging a wooden stick", "south"),
            ("hurt", "flinching and stumbling backwards", "south"),
            ("crouch", "crouching down small and hugging knees", "south"),
        ],
        "sheet": "assets/sprites/player/child_sheet_32.png",
        "colors": 24,
    },
    "briar": {
        "ref_sheet": "assets/reference/companion_briar_sheet_clean.png",
        "ref_cell": (0, 2, 296),  # trotting pose (sitting ref anchored all anims to sitting)
        "description": "small Belgian Malinois puppy, short fawn tan coat, black mask on muzzle, large dark upright ears with torn left ear, small bell collar, lean young build, pixel art",
        "anims": [
            ("trot_down", "trotting", "south"),
            ("trot_up", "trotting", "north"),
            ("trot_right", "trotting", "east"),
            ("sit", "sitting, ears flicking, looking around", "south"),
            ("dig", "digging energetically in the dirt", "east"),
            ("cower", "cowering low with ears flat and tail tucked", "south"),
            ("bark", "barking with alert stance", "east"),
        ],
        "sheet": "assets/sprites/companions/briar_pup_32.png",
        "colors": 20,
    },
    "twisted": {
        "ref_sheet": "assets/reference/monster_twisted_child_sheet_raw.png",
        "ref_cell": (0, 1, 0),  # cell size derived (4x4 grid); magenta-keyed
        "description": "small hunched grey creature in tattered rags, faded carnival clown neck ruff, face hidden in shadow, long thin fingers, dragging tiny wooden duck pull-toy on a string, pixel art",
        "anims": [
            ("walk_right", "slow shuffling hunched crawl", "east"),
            ("idle", "swaying slowly in place, hunched", "south"),
            ("lunge", "sudden forward lunge with arms out", "east"),
            ("stilled", "sitting calmly hugging the wooden duck toy", "south"),
        ],
        "sheet": "assets/sprites/enemies/twisted_child_32.png",
        "colors": 20,
    },
}


def strip_magenta_debris(frame: Image.Image) -> Image.Image:
    """PixelLab leaves stray magenta/pink pixels on transparent backgrounds.
    Unconditional hue strip (unlike pixelize.key_background, no 10% heuristic)."""
    import numpy as np
    arr = np.asarray(frame.convert("RGBA")).copy()
    r = arr[:, :, 0].astype(int)
    g = arr[:, :, 1].astype(int)
    b = arr[:, :, 2].astype(int)
    debris = (r > 120) & (b > 120) & (g < (r * 0.75)) & (g < (b * 0.75)) & ((r - g) > 40) & ((b - g) > 40)
    # light-pink stragglers: pink has b > g (skin tones have g > b, stay safe)
    light_pink = (r > 170) & (b > 140) & (b > g + 12) & (r > g + 25)
    arr[debris | light_pink, 3] = 0
    return Image.fromarray(arr, "RGBA")


def make_reference(char: str, cfg: dict) -> Path:
    ref_path = OUT / f"{char}_ref_64.png"
    if ref_path.exists():
        return ref_path
    img = Image.open(cfg["ref_sheet"])
    col, row, cell = cfg["ref_cell"]
    if cell == 0:
        cell = img.width // 4  # twisted: 4x4 grid
    crop = img.crop((col * cell, row * cell, (col + 1) * cell, (row + 1) * cell))
    crop = pixelize.key_background(crop)
    crop.resize((64, 64), Image.BOX).save(ref_path)
    print(f"reference: {ref_path}")
    return ref_path


def generate(only: str | None) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for char, cfg in CHARACTERS.items():
        if only and char != only:
            continue
        ref = make_reference(char, cfg)
        for anim, action, direction in cfg["anims"]:
            first = OUT / f"{char}_{anim}_0.png"
            if first.exists():
                print(f"skip {char}/{anim} (exists)")
                continue
            print(f"generating {char}/{anim} ({action}, {direction})...")
            result = call("animate-with-text", {
                "image_size": {"width": 64, "height": 64},
                "description": cfg["description"],
                "action": action,
                "direction": direction,
                "view": VIEW,
                "n_frames": 4,
                "image_guidance_scale": 8.0,
                "reference_image": b64_image(str(ref)),
            })
            import base64
            for i, img in enumerate(result.get("images", [])):
                data = base64.b64decode(img["base64"] if isinstance(img, dict) else img)
                (OUT / f"{char}_{anim}_{i}.png").write_bytes(data)
            print(f"  -> {len(result.get('images', []))} frames")
        print("balance:", call("balance", method="GET"))


def assemble() -> None:
    for char, cfg in CHARACTERS.items():
        rows = []
        for anim, _a, _d in cfg["anims"]:
            frames = sorted(OUT.glob(f"{char}_{anim}_*.png"))
            if not frames:
                print(f"MISSING {char}/{anim} — run generate first")
                return
            rows.append(frames[:4])
        cols = 4
        sheet = Image.new("RGBA", (cols * 32, len(rows) * 32), (0, 0, 0, 0))
        for r, frames in enumerate(rows):
            for c, fp in enumerate(frames):
                cell = strip_magenta_debris(pixelize.key_background(Image.open(fp)))
                frame = pixelize.pixelize_cell(cell, 32, cfg["colors"])
                sheet.paste(strip_magenta_debris(frame), (c * 32, r * 32))
        Path(cfg["sheet"]).parent.mkdir(parents=True, exist_ok=True)
        sheet.save(cfg["sheet"])
        preview = sheet.resize((sheet.width * 3, sheet.height * 3), Image.NEAREST)
        preview.save(cfg["sheet"].replace(".png", "_preview.png"))
        print(f"assembled {cfg['sheet']} ({len(rows)} anims)")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("cmd", choices=["generate", "assemble"])
    ap.add_argument("--only")
    args = ap.parse_args()
    if args.cmd == "generate":
        generate(args.only)
    else:
        assemble()


if __name__ == "__main__":
    main()
