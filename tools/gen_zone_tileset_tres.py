#!/usr/bin/env python3
"""Build the zone ground TileSet from the PixelLab Wang atlases.

Copies the 4 downloaded atlases (tools/pixellab_tilesets.py download) into
assets/sprites/tiles/ and writes ground_tileset.tres with one atlas source
per terrain pair. Source ids must match playground_fringes.gd SRC_*.
"""
import shutil
from pathlib import Path

SRC_DIR = Path("assets/reference/pixellab_tilesets")
DST_DIR = Path("assets/sprites/tiles")
TILE = 32

# tres path -> ordered atlas list (order defines source ids)
SETS = {
    "assets/resources/tiles/ground_tileset.tres":
        ["playground", "fringes", "ritual", "grass_blend"],
    "assets/resources/tiles/village_tileset.tres":
        ["village_green", "village_yard"],
}

# flat stand-in colors per atlas (lower, upper) until the real render lands
PLACEHOLDER_COLORS = {
    "village_green": ((116, 128, 72), (122, 120, 116)),
    "village_yard": ((116, 128, 72), (150, 128, 88)),
}


def _placeholder_atlas(name: str, dst: Path) -> None:
    from PIL import Image
    lower, upper = PLACEHOLDER_COLORS[name]
    atlas = Image.new("RGB", (4 * TILE, 4 * TILE))
    for idx in range(16):
        # idx bits NW NE SW SE: paint quadrants so transitions roughly read
        ox, oy = (idx % 4) * TILE, (idx // 4) * TILE
        half = TILE // 2
        quads = [(0, 0, 8), (half, 0, 4), (0, half, 2), (half, half, 1)]
        for qx, qy, bit in quads:
            color = upper if idx & bit else lower
            for y in range(half):
                for x in range(half):
                    atlas.putpixel((ox + qx + x, oy + qy + y), color)
    atlas.save(dst)
    print(f"placeholder atlas: {dst} (real render pending)")


def main() -> None:
    DST_DIR.mkdir(parents=True, exist_ok=True)
    for tres_path, atlases in SETS.items():
        _build_set(Path(tres_path), atlases)


def _build_set(tres: Path, atlases: list) -> None:
    tres.parent.mkdir(parents=True, exist_ok=True)
    ext_resources = []
    sub_resources = []
    source_lines = []
    for i, name in enumerate(atlases):
        src = SRC_DIR / f"{name}_tileset_{TILE}.png"
        dst = DST_DIR / f"{name}_tiles_{TILE}.png"
        if src.exists():
            shutil.copyfile(src, dst)
        elif not dst.exists():
            _placeholder_atlas(name, dst)
        ext_resources.append(
            f'[ext_resource type="Texture2D" path="res://{dst}" id="tex_{name}"]')
        tiles = "\n".join(f"{x}:{y}/0 = 0" for y in range(4) for x in range(4))
        sub_resources.append(
            f'[sub_resource type="TileSetAtlasSource" id="atlas_{name}"]\n'
            f'texture = ExtResource("tex_{name}")\n'
            f"texture_region_size = Vector2i({TILE}, {TILE})\n" + tiles + "\n")
        source_lines.append(f'sources/{i} = SubResource("atlas_{name}")')
    out = (f'[gd_resource type="TileSet" load_steps={len(atlases) * 2 + 1} format=3]\n\n'
           + "\n".join(ext_resources) + "\n\n"
           + "\n".join(sub_resources) + "\n[resource]\n"
           + f"tile_size = Vector2i({TILE}, {TILE})\n"
           + "\n".join(source_lines) + "\n")
    tres.write_text(out)
    print(f"wrote {tres} ({len(atlases)} sources)")


if __name__ == "__main__":
    main()
