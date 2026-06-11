#!/usr/bin/env python3
"""Pull village prop palettes toward the ground tiles (playtest 2026-06-11:
props read as stickers — reference-sheet saturation on muted dusk ground).
Desaturate-only (never boost), idempotent enough: re-running converges.
"""
import colorsys
from pathlib import Path

from PIL import Image

PROP_DIR = Path("assets/sprites/village")
TARGET_SAT = 0.40
MIN_FACTOR = 0.72


def mean_sat(img: Image.Image) -> float:
    s_total = n = 0
    for r, g, b, a in img.getdata():
        if a < 128:
            continue
        s_total += colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)[1]
        n += 1
    return s_total / max(n, 1)


def harmonize(path: Path) -> None:
    img = Image.open(path).convert("RGBA")
    sat = mean_sat(img)
    if sat <= TARGET_SAT + 0.02:
        print(f"{path.name}: sat={sat:.2f} ok")
        return
    factor = max(TARGET_SAT / sat, MIN_FACTOR)
    out = []
    for r, g, b, a in img.getdata():
        if a == 0:
            out.append((r, g, b, a))
            continue
        h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
        nr, ng, nb = colorsys.hsv_to_rgb(h, s * factor, v)
        out.append((int(nr * 255), int(ng * 255), int(nb * 255), a))
    img.putdata(out)
    img.save(path)
    print(f"{path.name}: sat {sat:.2f} -> ~{sat * factor:.2f} (x{factor:.2f})")


if __name__ == "__main__":
    for p in sorted(PROP_DIR.glob("*.png")):
        if p.name.startswith("_"):
            continue
        harmonize(p)
