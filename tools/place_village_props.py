#!/usr/bin/env python3
"""Inject the authored village prop placements into village_green.tscn.

One-shot and guarded: refuses to run twice (looks for PropChapel) and
refuses while any prop texture is missing — run it after the art lands.
Layout matches the mood shot: cottages on the yards, chapel north on its
forecourt, well/market/bench around the green, lantern posts on the ring,
the Harmony board by the chapel.
"""
from pathlib import Path

TSCN = Path("scenes/zones/village_green.tscn")
PROP_DIR = Path("assets/sprites/village")

# name, texture, x, y, sprite_offset_y, collision(kind,a,b), flip_h
PLACEMENTS = [
    ("PropCottageA", "cottage_a", -432, -330, -52, ("rect", 100, 16), False),
    ("PropCottageB", "cottage_b", 416, -330, -48, ("rect", 100, 16), False),
    ("PropCottageDark", "cottage_dark", -384, 290, -48, ("rect", 100, 16), False),
    ("PropCottagePieter", "cottage_b", 384, 290, -48, ("rect", 100, 16), True),
    ("PropChapel", "chapel", 0, -408, -76, ("rect", 110, 18), False),
    ("PropWell", "well", -40, -112, -20, ("circle", 14, 0), False),
    ("PropMarketStall", "market_stall", 300, -84, -32, ("rect", 80, 14), False),
    ("PropBench", "bench", 150, 68, -10, ("rect", 40, 8), False),
    ("PropHarmonyBoard", "harmony_board", 64, -352, -24, ("rect", 30, 8), False),
    ("PropLanternNE", "lantern_post", 158, -158, -24, ("circle", 4, 0), False),
    ("PropLanternNW", "lantern_post", -158, -158, -24, ("circle", 4, 0), True),
    ("PropLanternSE", "lantern_post", 158, 158, -24, ("circle", 4, 0), False),
    ("PropLanternSW", "lantern_post", -158, 158, -24, ("circle", 4, 0), True),
    ("PropFenceWestA", "fence", -560, -16, -8, ("rect", 56, 6), False),
    ("PropFenceWestB", "fence", -560, 96, -8, ("rect", 56, 6), False),
]


def main() -> None:
    src = TSCN.read_text()
    if "PropChapel" in src:
        print("props already placed — nothing to do")
        return
    missing = [t for _, t, *_ in PLACEMENTS if not (PROP_DIR / f"{t}.png").exists()]
    if missing:
        raise SystemExit(f"missing textures, not placing: {sorted(set(missing))}")

    textures = sorted({t for _, t, *_ in PLACEMENTS})
    ext = "".join(
        f'[ext_resource type="Texture2D" path="res://{PROP_DIR}/{t}.png" id="tex_{t}"]\n'
        for t in textures)
    shapes = []
    shape_lines = []
    for name, _t, _x, _y, _oy, (kind, a, b), _f in PLACEMENTS:
        sid = f"shape_{name}"
        if kind == "rect":
            shape_lines.append(f'[sub_resource type="RectangleShape2D" id="{sid}"]\n'
                               f"size = Vector2({a}, {b})\n")
        else:
            shape_lines.append(f'[sub_resource type="CircleShape2D" id="{sid}"]\n'
                               f"radius = {a}.0\n")
        shapes.append(sid)

    nodes = []
    for (name, tex, x, y, oy, _shape, flip), sid in zip(PLACEMENTS, shapes):
        flip_line = "flip_h = true\n" if flip else ""
        nodes.append(
            f'[node name="{name}" type="StaticBody2D" parent="World"]\n'
            f"position = Vector2({x}, {y})\n"
            "collision_layer = 1\ncollision_mask = 0\n\n"
            f'[node name="Sprite2D" type="Sprite2D" parent="World/{name}"]\n'
            f"position = Vector2(0, {oy})\n"
            f'texture = ExtResource("tex_{tex}")\n{flip_line}\n'
            f'[node name="CollisionShape2D" type="CollisionShape2D" parent="World/{name}"]\n'
            f'shape = SubResource("{sid}")\n')

    # bump load_steps: one ext_resource per unique texture + one shape per prop
    import re
    m = re.search(r"load_steps=(\d+)", src)
    src = src.replace(m.group(0), f"load_steps={int(m.group(1)) + len(textures) + len(PLACEMENTS)}")
    anchor_ext = '[sub_resource type="RectangleShape2D" id="RectangleShape2D_wall_h"]'
    src = src.replace(anchor_ext, ext + "\n" + "".join(shape_lines) + anchor_ext)
    anchor_node = '[node name="DreadOverlay" parent="." instance='
    src = src.replace(anchor_node, "\n".join(nodes) + "\n" + anchor_node)
    TSCN.write_text(src)
    print(f"placed {len(PLACEMENTS)} props into {TSCN}")


if __name__ == "__main__":
    main()
