#!/usr/bin/env python3
"""Full village-green mock — mirrors village_green.gd's painter (dirt paths)
and place_village_props.py placements. The approval artifact."""
import math
from pathlib import Path

from PIL import Image

import place_village_props as placements

TILE = 32
WIDTH, HEIGHT = 44, 28
RING_RADIUS, RING_HALF = 7.5, 1.0
LANE_HALF = 1
YARDS = [(-16, -11, 6, 4), (10, -11, 6, 4), (-15, 8, 6, 4), (9, 8, 6, 4)]
CHAPEL_COURT = (-2, -13, 5, 4)


def in_rect(r, vx, vy):
    return r[0] <= vx < r[0] + r[2] and r[1] <= vy < r[1] + r[3]


def vertex_is_dirt(vx: int, vy: int) -> bool:
    if abs(math.sqrt(vx * vx + vy * vy) - RING_RADIUS) <= RING_HALF:
        return True
    if abs(vy) <= LANE_HALF:
        return True
    if abs(vx) <= LANE_HALF and -10 <= vy < 0:
        return True
    if in_rect(CHAPEL_COURT, vx, vy):
        return True
    return any(in_rect(y, vx, vy) for y in YARDS)


def main() -> None:
    atlas = Image.open("assets/sprites/tiles/village_yard_tiles_32.png").convert("RGB")
    out = Image.new("RGB", (WIDTH * TILE, HEIGHT * TILE))
    for y in range(-HEIGHT // 2, HEIGHT // 2):
        for x in range(-WIDTH // 2, WIDTH // 2):
            idx = 0
            for c in (vertex_is_dirt(x, y), vertex_is_dirt(x + 1, y),
                      vertex_is_dirt(x, y + 1), vertex_is_dirt(x + 1, y + 1)):
                idx = idx << 1 | (1 if c else 0)
            tile = atlas.crop(((idx % 4) * TILE, (idx // 4) * TILE,
                               (idx % 4 + 1) * TILE, (idx // 4 + 1) * TILE))
            out.paste(tile, ((x + WIDTH // 2) * TILE, (y + HEIGHT // 2) * TILE))
    out = out.convert("RGBA")
    cx, cy = WIDTH * TILE // 2, HEIGHT * TILE // 2
    props_sorted = sorted(placements.PLACEMENTS, key=lambda p: p[3])
    # contact shadows first (mirrors PropShadows.apply)
    from PIL import ImageDraw
    shadow_layer = Image.new("RGBA", out.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(shadow_layer)
    for name, tex, px, py, oy, _shape, flip in props_sorted:
        img = Image.open(placements.PROP_DIR / f"{tex}.png")
        w = img.width * 0.82
        h = w * 0.34
        draw.ellipse([cx + px - w / 2, cy + py - 1 - h / 2,
                      cx + px + w / 2, cy + py - 1 + h / 2], fill=(0, 0, 0, 70))
    out.alpha_composite(shadow_layer)
    for name, tex, px, py, oy, _shape, flip in props_sorted:
        img = Image.open(placements.PROP_DIR / f"{tex}.png").convert("RGBA")
        if flip:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
        out.paste(img, (cx + px - img.width // 2, cy + py + oy - img.height // 2), img)
    # drop in two villagers for scale (idle_down cell, 48px)
    for sheet, px, py in (("villager_parent", -40, -60), ("villager_child", 30, 120)):
        cell = Image.open(f"assets/sprites/npcs/{sheet}_32.png").convert("RGBA") \
            .crop((0, 4 * 48, 48, 5 * 48))
        out.paste(cell, (cx + px - 24, cy + py - 24), cell)
    out.convert("RGB").save("/tmp/village_mock.png")
    dusk = Image.merge("RGB", [ch.point(lambda v, f=f: int(v * f))
                               for ch, f in zip(out.convert("RGB").split(), (0.38, 0.34, 0.44))])
    dusk.save("/tmp/village_mock_dusk.png")
    print("mock: /tmp/village_mock.png + _dusk.png")


if __name__ == "__main__":
    import sys
    sys.path.insert(0, str(Path(__file__).parent))
    main()
