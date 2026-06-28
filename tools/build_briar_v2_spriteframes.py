#!/usr/bin/env python3
"""First-pass wiring of the V2 puppy art into a Godot SpriteFrames.

The V2 frames are 124x124 with a small dog somewhere inside. This:
  1. finds one GLOBAL content bbox across every frame we use (so the dog keeps a
     consistent scale + anchor across animations — no size jitter),
  2. crops every frame to that bbox, scales the dog to fit a CELL-px cell, pastes
     it centered, and packs everything into one grid sheet, then
  3. writes a SpriteFrames .tres whose animation NAMES match what the game plays
     (see scripts/companions/companion_base.gd): idle_/walk_/trot_/stare_/growl_
     per direction, plus dig/bark/sit.

NOTE: these are rough text-to-animate drafts — this is a "see it in-game" pass, not
final. Hand polish (rigging, cleanup, mirroring) still belongs in a pixel editor.

Run: python3 tools/build_briar_v2_spriteframes.py
"""
from pathlib import Path
from PIL import Image
import random
import string

SRC = Path("assets/companions/briar/puppy_v2/anim")
SHEET_PNG = Path("assets/sprites/companions/briar_v2_pup.png")
TRES = Path("assets/resources/companions/briar_v2_frames.tres")
SHEET_RES = "res://assets/sprites/companions/briar_v2_pup.png"
CELL = 48           # match the existing briar cell size
DOG_FIT = 42        # target dog footprint within the cell (px), preserves aspect
ALPHA_MIN = 12      # ignore near-transparent edge pixels when finding content

# code anim name -> (v2 action, v2 direction, loop, fps). dir: south=down north=up
# east=right west=left. seek->stare, run->trot. dig/bark are single (south pose).
MAP = []
for code_act, v2_act, fps in [("idle", "idle", 5), ("walk", "walk", 8),
                              ("trot", "run", 10), ("stare", "seek", 6),
                              ("growl", "growl", 6)]:
    for code_dir, v2_dir in [("down", "south"), ("up", "north"),
                             ("left", "west"), ("right", "east")]:
        MAP.append((f"{code_act}_{code_dir}", v2_act, v2_dir, True, fps, 5))
# single-direction tells (code plays these non-directionally) + sit default
MAP.append(("dig", "dig", "south", True, 8, 5))
MAP.append(("bark", "bark", "south", True, 8, 5))
MAP.append(("sit", "idle", "south", True, 5, 1))  # stand-in: first idle pose
# poses the old briar sheet had but V2 didn't draft — single-frame stand-ins so
# the wiring is a true drop-in (behaviours/tests still find the animation names).
# Replace with dedicated art in the manual polish pass.
MAP.append(("cower", "idle", "south", True, 5, 1))
MAP.append(("dusk_press", "idle", "south", True, 5, 1))
MAP.append(("head_bump", "idle", "north", True, 5, 1))
MAP.append(("lie_down", "idle", "south", True, 5, 1))


def frame_paths(act: str, direction: str, count: int) -> list[Path]:
    d = SRC / act / direction
    return [d / f"frame_0{i}.png" for i in range(count)]


def content_bbox(img: Image.Image):
    # bbox of pixels with alpha >= ALPHA_MIN (None if fully transparent)
    a = img.getchannel("A").point(lambda v: 255 if v >= ALPHA_MIN else 0)
    return a.getbbox()


def union(b1, b2):
    if b1 is None:
        return b2
    if b2 is None:
        return b1
    return (min(b1[0], b2[0]), min(b1[1], b2[1]),
            max(b1[2], b2[2]), max(b1[3], b2[3]))


def main() -> None:
    # 1) global bbox across every used frame
    used = []
    for name, act, direction, loop, fps, n in MAP:
        used.append((name, act, direction, loop, fps, frame_paths(act, direction, n)))
    gb = None
    for _, _, _, _, _, paths in used:
        for p in paths:
            gb = union(gb, content_bbox(Image.open(p).convert("RGBA")))
    bx0, by0, bx1, by1 = gb
    bw, bh = bx1 - bx0, by1 - by0
    scale = DOG_FIT / max(bw, bh)
    sw, sh = max(1, round(bw * scale)), max(1, round(bh * scale))
    off_x = (CELL - sw) // 2
    off_y = (CELL - sh) // 2

    def process(p: Path) -> Image.Image:
        crop = Image.open(p).convert("RGBA").crop((bx0, by0, bx1, by1))
        crop = crop.resize((sw, sh), Image.NEAREST)
        cell = Image.new("RGBA", (CELL, CELL), (0, 0, 0, 0))
        cell.alpha_composite(crop, (off_x, off_y))
        return cell

    # 2) pack one row per animation, 5 cols
    cols = max(len(p) for *_, p in used)
    rows = len(used)
    sheet = Image.new("RGBA", (cols * CELL, rows * CELL), (0, 0, 0, 0))
    for r, (name, act, direction, loop, fps, paths) in enumerate(used):
        for c, p in enumerate(paths):
            sheet.alpha_composite(process(p), (c * CELL, r * CELL))
    SHEET_PNG.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(SHEET_PNG)

    # 3) emit SpriteFrames .tres (sheet + AtlasTexture regions)
    rng = random.Random("briar_v2")
    def uid(k=5):
        return "".join(rng.choices(string.ascii_lowercase + string.digits, k=k))
    atlases, anims = [], []
    for r, (name, act, direction, loop, fps, paths) in enumerate(used):
        refs = []
        for c in range(len(paths)):
            aid = f"AtlasTexture_{uid()}"
            atlases.append(
                f'[sub_resource type="AtlasTexture" id="{aid}"]\n'
                f'atlas = ExtResource("1_sheet")\n'
                f'region = Rect2({c * CELL}, {r * CELL}, {CELL}, {CELL})\n')
            refs.append('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % aid)
        anims.append("{\n"
                     f'"frames": [{", ".join(refs)}],\n'
                     f'"loop": {"true" if loop else "false"},\n'
                     f'"name": &"{name}",\n'
                     f'"speed": {float(fps)}\n}}')
    load_steps = len(atlases) + 2
    TRES.parent.mkdir(parents=True, exist_ok=True)
    TRES.write_text(
        f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]\n\n'
        f'[ext_resource type="Texture2D" path="{SHEET_RES}" id="1_sheet"]\n\n'
        + "\n".join(atlases)
        + "\n[resource]\nanimations = [" + ", ".join(anims) + "]\n",
        encoding="utf-8")
    print(f"global bbox={gb} dog {bw}x{bh} -> {sw}x{sh} in {CELL}px cell")
    print(f"wrote {SHEET_PNG} ({cols*CELL}x{rows*CELL}) and {TRES} ({len(used)} anims)")


if __name__ == "__main__":
    main()
