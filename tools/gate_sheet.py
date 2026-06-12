#!/usr/bin/env python3
"""gate_sheet.py — rule-5 projection gate contact sheet (editor-less QA).

Composites assets/reference/qa_overlay_128.png (centered, ~70% opacity) onto
every PNG in assets/sprites/village/candidates/ at 4x nearest-neighbor and
writes one contact sheet for eyeball review in any image viewer.

Read with assets/reference/qa_overlay_legend.png: prop ground circles must
match the GREEN ellipses (0.34 = low top-down ~20 deg); the RED ellipse
(0.57 = high top-down ~35 deg) is the reject reference. Verticals must stay
vertical against the ruler; canon box = top 1 : front 3.

Usage: python3 tools/gate_sheet.py [--out gate_sheet.png] [files...]
       (default files: assets/sprites/village/candidates/*.png)
"""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OVERLAY = ROOT / "assets/reference/qa_overlay_128.png"
CANDIDATES = ROOT / "assets/sprites/village/candidates"
SCALE = 4
OVERLAY_ALPHA = 0.7
LABEL_H = 14


def gate_cell(png: Path, overlay: Image.Image) -> Image.Image:
    sprite = Image.open(png).convert("RGBA")
    cell = Image.new("RGBA", overlay.size, (58, 58, 58, 255))
    cell.alpha_composite(
        sprite,
        ((cell.width - sprite.width) // 2, (cell.height - sprite.height) // 2),
    )
    faded = overlay.copy()
    alpha = faded.getchannel("A").point(lambda a: int(a * OVERLAY_ALPHA))
    faded.putalpha(alpha)
    cell.alpha_composite(faded)
    return cell.resize((cell.width * SCALE, cell.height * SCALE), Image.NEAREST)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("files", nargs="*", type=Path,
                    help="prop PNGs (default: candidates/*.png)")
    ap.add_argument("--out", type=Path, default=Path("gate_sheet.png"))
    args = ap.parse_args()

    files = args.files or sorted(CANDIDATES.glob("*.png"))
    if not files:
        raise SystemExit("no candidate PNGs found")
    overlay = Image.open(OVERLAY).convert("RGBA")

    cells = [(f.stem, gate_cell(f, overlay)) for f in files]
    cw, ch = cells[0][1].size
    sheet = Image.new("RGBA", (cw * len(cells), ch + LABEL_H * SCALE),
                      (30, 30, 30, 255))
    try:
        from PIL import ImageDraw
        draw = ImageDraw.Draw(sheet)
    except ImportError:  # pragma: no cover
        draw = None
    for i, (name, cell) in enumerate(cells):
        sheet.paste(cell, (i * cw, 0))
        if draw:
            draw.text((i * cw + 8, ch + 8), name, fill=(230, 230, 230, 255))
    sheet.save(args.out)
    print(f"gate sheet: {args.out} ({len(cells)} props) — read with "
          f"assets/reference/qa_overlay_legend.png")


if __name__ == "__main__":
    main()
