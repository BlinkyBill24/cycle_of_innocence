#!/usr/bin/env python3
"""Programmatic pixel-art pass: slice an AI-generated sprite sheet into grid
cells, downscale each to true NxN pixels, quantize to a limited palette, and
reassemble a clean import-ready sheet (+ optional zoomed preview).

Placeholder-quality by design (AGENTS.md art pipeline) — hand Aseprite polish
or Retro Diffusion replaces this when quality walls are hit.

Usage:
  python3 tools/pixelize.py IN.png OUT.png --cols 6 --rows 8 \
      [--size 32] [--colors 24] [--inset 0.06] [--preview]
"""
import argparse
from PIL import Image


def pixelize_cell(cell: Image.Image, size: int, colors: int) -> Image.Image:
    cell = cell.convert("RGBA")
    small = cell.resize((size, size), Image.BOX)
    rgb = small.convert("RGB").quantize(colors=colors, method=Image.Quantize.FASTOCTREE)
    out = rgb.convert("RGBA")
    # restore hard-edged alpha from the downscaled cell
    alpha = small.getchannel("A").point(lambda a: 255 if a >= 128 else 0)
    out.putalpha(alpha)
    return out


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--cols", type=int, required=True)
    ap.add_argument("--rows", type=int, required=True)
    ap.add_argument("--size", type=int, default=32, help="target frame size (px)")
    ap.add_argument("--colors", type=int, default=24, help="palette size")
    ap.add_argument("--inset", type=float, default=0.06,
                    help="fraction of each cell cropped on every side (drops gridlines)")
    ap.add_argument("--preview", action="store_true", help="also write OUT_preview.png at 4x")
    args = ap.parse_args()

    src = Image.open(args.input).convert("RGBA")
    cell_w = src.width / args.cols
    cell_h = src.height / args.rows
    sheet = Image.new("RGBA", (args.cols * args.size, args.rows * args.size), (0, 0, 0, 0))

    for row in range(args.rows):
        for col in range(args.cols):
            x0 = col * cell_w + cell_w * args.inset
            y0 = row * cell_h + cell_h * args.inset
            x1 = (col + 1) * cell_w - cell_w * args.inset
            y1 = (row + 1) * cell_h - cell_h * args.inset
            cell = src.crop((round(x0), round(y0), round(x1), round(y1)))
            frame = pixelize_cell(cell, args.size, args.colors)
            sheet.paste(frame, (col * args.size, row * args.size))

    sheet.save(args.output, "PNG")
    print(f"wrote {args.output} ({sheet.width}x{sheet.height}, "
          f"{args.cols}x{args.rows} frames @ {args.size}px, {args.colors} colors)")

    if args.preview:
        preview_path = args.output.replace(".png", "_preview.png")
        sheet.resize((sheet.width * 4, sheet.height * 4), Image.NEAREST).save(preview_path)
        print(f"wrote {preview_path}")


if __name__ == "__main__":
    main()
