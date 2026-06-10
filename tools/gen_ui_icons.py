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
