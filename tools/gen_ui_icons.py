#!/usr/bin/env python3
"""Generate tiny UI pixel icons (hearts) — text glyphs don't render in the
web export's minimal fallback font."""
from PIL import Image

HEART = [
    ".XX.XX.",
    "XXXXXXX",
    "XXXXXXX",
    ".XXXXX.",
    "..XXX..",
    "...X...",
]

def make(color, outline):
    img = Image.new("RGBA", (8, 8), (0, 0, 0, 0))
    for y, row in enumerate(HEART):
        for x, ch in enumerate(row):
            if ch == "X":
                img.putpixel((x, y + 1), color)
    # simple dark outline pass
    out = img.copy()
    for y in range(8):
        for x in range(8):
            if img.getpixel((x, y))[3] == 0:
                for nx, ny in ((x-1,y),(x+1,y),(x,y-1),(x,y+1)):
                    if 0 <= nx < 8 and 0 <= ny < 8 and img.getpixel((nx, ny))[3] > 0:
                        out.putpixel((x, y), outline)
                        break
    return out

make((204, 51, 64, 255), (40, 10, 14, 255)).save("assets/sprites/ui/heart_full.png")
make((60, 52, 56, 255), (30, 24, 26, 255)).save("assets/sprites/ui/heart_empty.png")
print("wrote heart_full.png + heart_empty.png")


# Briar's seek/bark "tell". The old version was a thin 6x8 pale glyph with no
# outline — at 2x scale it read as an illegible yellow blob (diagnosed live via
# the runtime MCP server, 2026-06-28). This one is bigger, bolder and dark-
# outlined: a tapering exclamation bar + a chunky dot, vivid alert-yellow with a
# top-left highlight, so it pops above the dog's head and reads at a glance.
EXCLAIM = [
    ".####.",
    ".####.",
    ".####.",
    ".####.",
    ".####.",
    ".####.",
    "......",
    ".####.",
    ".####.",
]
EXCLAIM_FILL = (255, 205, 60, 255)
EXCLAIM_HILITE = (255, 240, 150, 255)
EXCLAIM_OUTLINE = (40, 22, 10, 255)

def _is_fill(rows, x, y):
    return 0 <= y < len(rows) and 0 <= x < len(rows[0]) and rows[y][x] == "#"

def make_exclaim():
    # core glyph centered in a canvas with a 2px margin for the outline
    cw, ch = len(EXCLAIM[0]), len(EXCLAIM)
    margin = 2
    w, h = cw + margin * 2, ch + margin * 2
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, row in enumerate(EXCLAIM):
        for x, c in enumerate(row):
            if c != "#":
                continue
            # top-left bevel: a fill pixel exposed above or to the left catches
            # the light → highlight; interior pixels stay the base fill.
            hi = not _is_fill(EXCLAIM, x, y - 1) or not _is_fill(EXCLAIM, x - 1, y)
            img.putpixel((x + margin, y + margin),
                         EXCLAIM_HILITE if hi else EXCLAIM_FILL)
    # 8-neighbour dark outline pass around every fill pixel (clean border all round)
    out = img.copy()
    for y in range(h):
        for x in range(w):
            if img.getpixel((x, y))[3] != 0:
                continue
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and img.getpixel((nx, ny))[3] > 0:
                        out.putpixel((x, y), EXCLAIM_OUTLINE)
                        break
                else:
                    continue
                break
    return out

make_exclaim().save("assets/sprites/ui/exclaim.png")
print("wrote exclaim.png")
