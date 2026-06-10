#!/usr/bin/env python3
"""Generate the placeholder ground-tile atlas (seamless flat tiles + pixel
noise). Replaceable later by hand-cleaned tiles from the Grok tileset refs.

Tiles (32px, left to right):
  0 playground grass (warm dusk)   1 trampled path (tan)
  2 fringes grass (cold)           3 forest floor (dark)
  4 ritual sand (pale)
"""
import random
from PIL import Image

SIZE = 32
TILES = [
    ((96, 102, 58), (84, 90, 50)),    # warm dusk grass
    ((150, 128, 88), (138, 117, 79)),  # trampled path
    ((58, 74, 56), (50, 65, 49)),      # cold fringes grass
    ((52, 44, 36), (45, 38, 31)),      # forest floor
    ((178, 160, 118), (166, 149, 109)),# ritual sand
]

rng = random.Random(7)
atlas = Image.new("RGB", (SIZE * len(TILES), SIZE))
for i, (base, dark) in enumerate(TILES):
    for y in range(SIZE):
        for x in range(SIZE):
            color = dark if rng.random() < 0.22 else base
            if rng.random() < 0.04:  # sparse bright speck
                color = tuple(min(c + 14, 255) for c in base)
            atlas.putpixel((i * SIZE + x, y), color)

out = "assets/sprites/tiles/ground_tiles_32.png"
atlas.save(out)
print(f"wrote {out} ({atlas.width}x{atlas.height})")
