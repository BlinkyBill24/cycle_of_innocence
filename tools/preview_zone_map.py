#!/usr/bin/env python3
"""Render the repainted zone as a PNG mock — the approval artifact before the
tiles ever hit Godot. MUST mirror playground_fringes.gd exactly:
vertex_terrain / wang_tile / path_wobble / fringe_edge.
"""
import math
from pathlib import Path

from PIL import Image

TILE = 32
WIDTH, HEIGHT = 44, 26
WARM, COLD, FLOOR, PATH, SAND = range(5)
SRC_PLAYGROUND, SRC_FRINGES, SRC_RITUAL, SRC_BLEND = range(4)
PAIR_SOURCES = {(WARM, PATH): SRC_PLAYGROUND, (WARM, SAND): SRC_RITUAL,
                (WARM, COLD): SRC_BLEND, (COLD, FLOOR): SRC_FRINGES}
PATH_END_X = -1
SAND_RECT = (-16, -9, 10, 5)
DUSK_TINT = (0.38, 0.34, 0.44)  # CanvasModulate mock


def path_wobble(x: int) -> int:
    return round(math.sin(x * 0.35) * 2.0)


def fringe_edge(vy: int) -> int:
    return 3 + round(2.0 * math.sin(vy * 0.45))


def hash01(ix: int, iy: int) -> float:
    # GDScript ints are 64-bit two's complement; Python XOR on negatives
    # matches after the & mask
    h = ((ix * 73856093) ^ (iy * 19349663)) & 0x7FFFFFFF
    return (h % 1000) / 999.0


def smoothstep(t: float) -> float:
    return t * t * (3.0 - 2.0 * t)


def value_noise(x: float, y: float) -> float:
    x0, y0 = math.floor(x), math.floor(y)
    fx, fy = smoothstep(x - x0), smoothstep(y - y0)
    top = hash01(x0, y0) + (hash01(x0 + 1, y0) - hash01(x0, y0)) * fx
    bottom = hash01(x0, y0 + 1) + (hash01(x0 + 1, y0 + 1) - hash01(x0, y0 + 1)) * fx
    return top + (bottom - top) * fy


def blob_noise(vx: int, vy: int) -> bool:
    return value_noise(vx / 3.0, vy / 3.0) > 0.60


def vertex_terrain(vx: int, vy: int) -> int:
    if vx <= PATH_END_X and abs(vy - path_wobble(vx)) <= 1:
        return PATH
    sx, sy, sw, sh = SAND_RECT
    if sx <= vx < sx + sw and sy <= vy < sy + sh:
        return SAND
    edge = fringe_edge(vy)
    if vx >= edge:
        if vx >= edge + 5 and blob_noise(vx, vy):
            return FLOOR
        return COLD
    return WARM


def pure_tile(t: int):
    return {PATH: (SRC_PLAYGROUND, 15), SAND: (SRC_RITUAL, 15),
            COLD: (SRC_FRINGES, 0), FLOOR: (SRC_FRINGES, 15)}.get(t, (SRC_PLAYGROUND, 0))


def wang_tile(nw: int, ne: int, sw: int, se: int):
    corners = [nw, ne, sw, se]
    kinds = set(corners)
    if len(kinds) == 1:
        return pure_tile(nw)
    if len(kinds) == 2:
        for (lo, up), src in PAIR_SOURCES.items():
            if lo in kinds and up in kinds:
                idx = 0
                for c in corners:
                    idx = idx << 1 | (1 if c == up else 0)
                return (src, idx)
    return None  # invalid mix — caller decides (mock marks it red)


# (texture, zone px, zone py, sprite y-offset, flip_h) — mirrors the
# World/* StaticBody2D placements in playground_fringes.tscn
PROPS = [
    ("swing_set", -430, -250, -26, False),
    ("slide", -290, -210, -26, False),
    ("roundabout", -460, -180, -18, False),
    ("totem_bear", -516, -150, -20, False),
    ("totem_rabbit", -220, -290, -20, False),
    ("dead_tree_a", 330, -200, -44, False),
    ("dead_tree_b", 495, 295, -36, False),
    ("dead_tree_a", 655, -255, -44, True),
    ("toy_duck", -360, -170, -12, False),
]


def overlay_props(out: Image.Image) -> None:
    props_dir = Path("assets/sprites/props")
    cx, cy = WIDTH * TILE // 2, HEIGHT * TILE // 2
    for name, px, py, oy, flip in sorted(PROPS, key=lambda p: p[2]):
        path = props_dir / f"{name}.png"
        if not path.exists():
            continue
        img = Image.open(path).convert("RGBA")
        if flip:
            img = img.transpose(Image.FLIP_LEFT_RIGHT)
        out.paste(img, (cx + px - img.width // 2,
                        cy + py + oy - img.height // 2), img)


def main() -> None:
    ref = Path("assets/reference/pixellab_tilesets")
    atlases = [Image.open(ref / f"{n}_tileset_{TILE}.png").convert("RGB")
               for n in ("playground", "fringes", "ritual", "grass_blend")]
    out = Image.new("RGB", (WIDTH * TILE, HEIGHT * TILE))
    invalid = 0
    for y in range(-HEIGHT // 2, HEIGHT // 2):
        for x in range(-WIDTH // 2, WIDTH // 2):
            pick = wang_tile(vertex_terrain(x, y), vertex_terrain(x + 1, y),
                             vertex_terrain(x, y + 1), vertex_terrain(x + 1, y + 1))
            px, py = (x + WIDTH // 2) * TILE, (y + HEIGHT // 2) * TILE
            if pick is None:
                invalid += 1
                out.paste(Image.new("RGB", (TILE, TILE), (255, 0, 0)), (px, py))
                continue
            src, idx = pick
            tile = atlases[src].crop(((idx % 4) * TILE, (idx // 4) * TILE,
                                      (idx % 4 + 1) * TILE, (idx // 4 + 1) * TILE))
            out.paste(tile, (px, py))
    out = out.convert("RGBA")
    overlay_props(out)
    out = out.convert("RGB")
    out.save("/tmp/zone_mock_raw.png")
    tinted = Image.eval(out, lambda v: v)  # copy
    tinted = Image.merge("RGB", [ch.point(lambda v, f=f: int(v * f))
                                 for ch, f in zip(out.split(), DUSK_TINT)])
    tinted.save("/tmp/zone_mock_dusk.png")
    print(f"mock: /tmp/zone_mock_raw.png + _dusk.png ({out.width}x{out.height}), "
          f"invalid cells: {invalid}")


if __name__ == "__main__":
    main()
