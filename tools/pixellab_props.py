#!/usr/bin/env python3
"""Zone props via PixelLab create-image-pixflux (sync, transparent bg).

The playground decor IS the horror beat: ritual equipment, stitched-toy
totems, dead trees for the fringes. Saved to assets/sprites/props/ plus a
3x preview strip for approval.

Usage: python3 tools/pixellab_props.py [--only NAME]
"""
import argparse
import base64
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).parent))
from pixellab_v2 import call  # noqa: E402

OUT = Path("assets/sprites/props")
STYLE = ("retro pixel art, SNES-style top-down RPG object, muted dusk palette, "
         "subtle horror edge, crisp pixels, no anti-aliasing, single object centered")

# name: (width, height, description)
PROPS = {
    "swing_set": (96, 64,
        "rusty playground swing set, metal A-frame, two chain swings, one seat "
        "broken dangling from a single chain, faded peeling red paint"),
    "slide": (64, 64,
        "small old playground slide, faded blue metal, rusted ladder, "
        "slightly leaning"),
    "roundabout": (64, 48,
        "rusted playground merry-go-round roundabout, circular metal platform "
        "with bent handle bars, faded paint"),
    "totem_bear": (32, 48,
        "hand-stitched teddy bear strapped upright to a wooden stake, "
        "mismatched button eyes, crude thick stitches, slightly leaning"),
    "totem_rabbit": (32, 48,
        "hand-stitched rabbit doll nailed to a wooden pole, long ears sagging, "
        "crude patchwork fabric, one button eye missing"),
    "dead_tree_a": (64, 96,
        "gnarled dead tree, bare twisted branches reaching sideways, dark bark, "
        "no leaves"),
    "dead_tree_b": (64, 80,
        "dead tree with snapped trunk, splintered break, one bare branch "
        "remaining, dark bark"),
    "toy_duck": (32, 32,  # API minimum canvas is 32x32
        "small abandoned wooden duck pull toy on wheels with a frayed string, "
        "faded yellow paint"),
}


def generate(only: str | None = None) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (w, h, desc) in PROPS.items():
        if only and name != only:
            continue
        path = OUT / f"{name}.png"
        if path.exists() and not only:
            print(f"skip {name} (exists)")
            continue
        result = call("create-image-pixflux", {
            "description": f"{desc}, {STYLE}",
            "image_size": {"width": w, "height": h},
            "no_background": True,
            "view": "low top-down",
        })
        img_entry = result.get("image") or {}
        path.write_bytes(base64.b64decode(img_entry["base64"]))
        print(f"{name}: {path}")
    _preview_strip()
    print("balance:", call("balance", method="GET")["credits"]["usd"])


def _preview_strip() -> None:
    imgs = [(n, Image.open(OUT / f"{n}.png").convert("RGBA"))
            for n in PROPS if (OUT / f"{n}.png").exists()]
    if not imgs:
        return
    gap = 8
    width = sum(i.width for _, i in imgs) + gap * (len(imgs) + 1)
    height = max(i.height for _, i in imgs) + gap * 2
    strip = Image.new("RGBA", (width, height), (45, 45, 55, 255))
    x = gap
    for _, img in imgs:
        strip.paste(img, (x, height - gap - img.height), img)
        x += img.width + gap
    strip.resize((strip.width * 3, strip.height * 3), Image.NEAREST).save(
        OUT / "_props_preview.png")
    print(f"preview: {OUT / '_props_preview.png'}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--only")
    args = ap.parse_args()
    generate(args.only)
