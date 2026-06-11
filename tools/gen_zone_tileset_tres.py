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
TRES = Path("assets/resources/tiles/ground_tileset.tres")
TILE = 32

# order defines source ids: 0 playground, 1 fringes, 2 ritual, 3 grass_blend
ATLASES = ["playground", "fringes", "ritual", "grass_blend"]


def main() -> None:
    DST_DIR.mkdir(parents=True, exist_ok=True)
    ext_resources = []
    sub_resources = []
    source_lines = []
    for i, name in enumerate(ATLASES):
        src = SRC_DIR / f"{name}_tileset_{TILE}.png"
        dst = DST_DIR / f"{name}_tiles_{TILE}.png"
        shutil.copyfile(src, dst)
        ext_resources.append(
            f'[ext_resource type="Texture2D" path="res://{dst}" id="tex_{name}"]')
        tiles = "\n".join(f"{x}:{y}/0 = 0" for y in range(4) for x in range(4))
        sub_resources.append(
            f'[sub_resource type="TileSetAtlasSource" id="atlas_{name}"]\n'
            f'texture = ExtResource("tex_{name}")\n'
            f"texture_region_size = Vector2i({TILE}, {TILE})\n" + tiles + "\n")
        source_lines.append(f'sources/{i} = SubResource("atlas_{name}")')
    out = (f'[gd_resource type="TileSet" load_steps={len(ATLASES) * 2 + 1} format=3]\n\n'
           + "\n".join(ext_resources) + "\n\n"
           + "\n".join(sub_resources) + "\n[resource]\n"
           + f"tile_size = Vector2i({TILE}, {TILE})\n"
           + "\n".join(source_lines) + "\n")
    TRES.write_text(out)
    print(f"wrote {TRES} ({len(ATLASES)} sources)")


if __name__ == "__main__":
    main()
