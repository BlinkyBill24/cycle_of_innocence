#!/usr/bin/env python3
"""Generate a Godot SpriteFrames .tres from a fixed-grid sprite sheet.

Each --anim maps one sheet row to one animation:
  --anim NAME:ROW:FRAMES:LOOP:FPS   e.g.  --anim walk_down:0:6:loop:8

Usage:
  python3 tools/gen_spriteframes.py res://assets/sprites/enemies/twisted_child_32.png \
      assets/resources/enemies/twisted_child_frames.tres --size 32 \
      --anim walk_down:0:6:loop:8 --anim idle:4:4:loop:5 ...
"""
import argparse
import random
import string


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("texture", help="res:// path of the sheet texture")
    ap.add_argument("output", help="output .tres file path")
    ap.add_argument("--size", type=int, default=32)
    ap.add_argument("--anim", action="append", required=True,
                    metavar="NAME:ROW:FRAMES:LOOP|once:FPS")
    args = ap.parse_args()

    rng = random.Random(args.texture + args.output)
    def uid(n=5):
        return "".join(rng.choices(string.ascii_lowercase + string.digits, k=n))

    atlases: list[str] = []
    anims: list[str] = []
    for spec in args.anim:
        name, row, frames, loop, fps = spec.split(":")
        frame_refs = []
        for col in range(int(frames)):
            aid = f"AtlasTexture_{uid()}"
            atlases.append(
                f'[sub_resource type="AtlasTexture" id="{aid}"]\n'
                f'atlas = ExtResource("1_sheet")\n'
                f"region = Rect2({int(col) * args.size}, {int(row) * args.size}, "
                f"{args.size}, {args.size})\n"
            )
            frame_refs.append(
                '{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % aid)
        anims.append(
            "{\n"
            f'"frames": [{", ".join(frame_refs)}],\n'
            f'"loop": {"true" if loop == "loop" else "false"},\n'
            f'"name": &"{name}",\n'
            f'"speed": {float(fps)}\n'
            "}"
        )

    load_steps = len(atlases) + 2
    out = (
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]\n\n'
        f'[ext_resource type="Texture2D" path="{args.texture}" id="1_sheet"]\n\n'
        + "\n".join(atlases)
        + "\n[resource]\nanimations = [" + ", ".join(anims) + "]\n"
    )
    with open(args.output, "w", encoding="utf-8") as fh:
        fh.write(out)
    print(f"wrote {args.output} ({len(args.anim)} animations, {len(atlases)} frames)")


if __name__ == "__main__":
    main()
