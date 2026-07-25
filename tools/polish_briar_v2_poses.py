#!/usr/bin/env python3
"""Gentle pose polish for Briar V2 Imagine drafts (cower/dusk_press/head_bump/lie_down).

- Hard alpha (drop soft AA fringe)
- Kill near-black semi-transparent edge noise
- Backs up originals under anim/_pre_polish_poses/ once

Does NOT palette-quantize (that destroyed identity in a trial pass).
After this, re-run: python3 tools/build_briar_v2_spriteframes.py

Usage: python3 tools/polish_briar_v2_poses.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image

SRC = Path("assets/companions/briar/puppy_v2/anim")
BACKUP = SRC / "_pre_polish_poses"
POSE_ACTS = ("cower", "dusk_press", "head_bump", "lie_down")
ALPHA_CUT = 100


def polish(im: Image.Image) -> Image.Image:
    px = im.convert("RGBA").load()
    w, h = im.size
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    op = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < ALPHA_CUT or (r < 28 and g < 28 and b < 28 and a < 220):
                op[x, y] = (0, 0, 0, 0)
            else:
                op[x, y] = (r, g, b, 255)
    return out


def main() -> None:
    n = 0
    for act in POSE_ACTS:
        for p in sorted((SRC / act).rglob("frame_*.png")):
            rel = p.relative_to(SRC)
            bak = BACKUP / rel
            bak.parent.mkdir(parents=True, exist_ok=True)
            if not bak.exists():
                Image.open(p).save(bak)
                src_im = Image.open(bak)
            else:
                # re-polish from backup so re-runs are idempotent
                src_im = Image.open(bak)
            polish(src_im).save(p)
            n += 1
            print("polished", rel)
    print(f"done {n} frames → re-run tools/build_briar_v2_spriteframes.py")


if __name__ == "__main__":
    main()
