#!/usr/bin/env python3
"""Full village-green mock — mirrors village_green.gd's painter (organic
lanes, terrace rim, variation scatter) + prop placements + the chapel
courtyard set-piece. The approval artifact; keep in sync with the GDScript."""
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from PIL import Image, ImageDraw

import place_village_props as placements

TILE = 32
WIDTH, HEIGHT = 44, 28
RING_RADIUS, RING_HALF = 7.5, 1.0
LANE_HALF = 1
YARDS = [(-16, -10, 6, 4), (10, -10, 6, 4), (-15, 8, 6, 4), (9, 8, 6, 4)]
CHAPEL_COURT = (-2, -13, 5, 4)
TERRACE_EDGE_Y, TERRACE_GAP_X = -12, 6
GREEN, DIRT, TERRACE = 0, 1, 2
GRASS_VARIANTS, DIRT_VARIANTS, PLAIN_CHANCE = 6, 1, 0.72


def hash01(ix, iy):
    h = ((ix * 73856093) ^ (iy * 19349663)) & 0x7FFFFFFF
    return (h % 1000) / 999.0


def in_rect(r, vx, vy):
    return r[0] <= vx < r[0] + r[2] and r[1] <= vy < r[1] + r[3]


def lane_wobble(vx):
    return round(math.sin(vx * 0.23) * 2.0)


def north_lane_wobble(vy):
    return round(math.sin(vy * 0.31) * 1.5)


def vertex_terrain(vx, vy):
    if vy <= TERRACE_EDGE_Y and abs(vx) >= TERRACE_GAP_X:
        return TERRACE
    jitter = (hash01(vx, vy) - 0.5) * 0.9
    dist = math.sqrt(vx * vx + vy * vy)
    if abs(dist - (RING_RADIUS + jitter)) <= RING_HALF:
        return DIRT
    dy = abs(vy - lane_wobble(vx))
    if dy <= LANE_HALF or (dy == LANE_HALF + 1 and hash01(vx, vy) < 0.28):
        return DIRT
    if -11 <= vy < 0 and abs(vx - north_lane_wobble(vy)) <= 1:
        return DIRT
    if in_rect(CHAPEL_COURT, vx, vy):
        return DIRT
    return DIRT if any(in_rect(yd, vx, vy) for yd in YARDS) else GREEN


def green_cell(x, y):
    h = hash01(x * 3 + 11, y * 5 + 7)
    if h < PLAIN_CHANCE:
        return ("yard", 0)
    return ("grass_var", min(int((h - PLAIN_CHANCE) / (1 - PLAIN_CHANCE) * GRASS_VARIANTS),
                             GRASS_VARIANTS - 1))


def dirt_cell(x, y):
    h = hash01(x * 7 + 3, y * 3 + 13)
    if h < 0.93:
        return ("yard", 15)
    return ("dirt_var", min(int((h - 0.93) / 0.07 * DIRT_VARIANTS), DIRT_VARIANTS - 1))


def cell_tile(x, y):
    corners = [vertex_terrain(x, y), vertex_terrain(x + 1, y),
               vertex_terrain(x, y + 1), vertex_terrain(x + 1, y + 1)]
    kinds = set(corners)
    if kinds == {GREEN}:
        return green_cell(x, y)
    if kinds == {DIRT}:
        return dirt_cell(x, y)
    if kinds == {TERRACE}:
        return ("terrace", 15)
    for lo, up, src in ((GREEN, DIRT, "yard"), (GREEN, TERRACE, "terrace")):
        if kinds == {lo, up}:
            idx = 0
            for c in corners:
                idx = idx << 1 | (1 if c == up else 0)
            return (src, idx)
    return ("yard", 0)


def main():
    atlases = {
        "yard": Image.open("assets/sprites/tiles/village_yard_tiles_32.png").convert("RGB"),
        "terrace": Image.open("assets/sprites/tiles/village_terrace_tiles_32.png").convert("RGB"),
        "grass_var": Image.open("assets/sprites/tiles/grass_variants_tiles_32.png").convert("RGB"),
        "dirt_var": Image.open("assets/sprites/tiles/dirt_variants_tiles_32.png").convert("RGB"),
    }
    out = Image.new("RGB", (WIDTH * TILE, HEIGHT * TILE))
    for y in range(-HEIGHT // 2, HEIGHT // 2):
        for x in range(-WIDTH // 2, WIDTH // 2):
            src_name, idx = cell_tile(x, y)
            atlas = atlases[src_name]
            cols = atlas.width // TILE
            tile = atlas.crop(((idx % cols) * TILE, (idx // cols) * TILE,
                               (idx % cols + 1) * TILE, (idx // cols + 1) * TILE))
            out.paste(tile, ((x + WIDTH // 2) * TILE, (y + HEIGHT // 2) * TILE))
    out = out.convert("RGBA")
    cx, cy = WIDTH * TILE // 2, HEIGHT * TILE // 2
    court = Image.open("assets/sprites/village/chapel_courtyard.png").convert("RGBA")
    out.alpha_composite(court, (cx + 16 - court.width // 2, cy - 352 - court.height // 2))
    props_sorted = sorted(placements.PLACEMENTS, key=lambda p: p[3])
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
    main()
