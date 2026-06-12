#!/usr/bin/env python3
"""palette_lock.py — quantize prop sprites to a zone backdrop's palette.

Prop-coherence rule 1 (docs/art/prop-coherence.md): every prop must use only
colors from its zone's painted ground backdrop (48-color quantized), so props
can never carry a foreign palette/temperature onto the ground they stand on.
Alpha is preserved untouched; only RGB of visible pixels is remapped to the
nearest palette color (Euclidean RGB).

Usage:
  python3 tools/palette_lock.py --backdrop assets/sprites/village/village_ground_backdrop.png \
      assets/sprites/village/well.png [more props...]
  python3 tools/palette_lock.py --backdrop ... --dry-run props...   # report only

Re-run `godot --headless --import` (or tools/run-tests.sh) after locking so
the editor picks up the changed textures.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image


def backdrop_palette(path: Path) -> list[tuple[int, int, int]]:
    im = Image.open(path).convert("RGBA")
    colors = {p[:3] for p in im.getdata() if p[3] > 0}
    if len(colors) > 64:
        print(f"WARN: backdrop has {len(colors)} colors — expected a "
              "quantized (~48 color) backdrop; is this the right file?",
              file=sys.stderr)
    return sorted(colors)


def nearest(color: tuple[int, int, int], palette: list[tuple[int, int, int]],
            cache: dict) -> tuple[int, int, int]:
    hit = cache.get(color)
    if hit is not None:
        return hit
    r, g, b = color
    best = min(palette, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
    cache[color] = best
    return best


def lock_file(path: Path, palette: list[tuple[int, int, int]],
              palette_set: set, dry_run: bool) -> None:
    im = Image.open(path).convert("RGBA")
    pixels = list(im.getdata())
    cache: dict = {}
    changed = 0
    visible = 0
    out = []
    for p in pixels:
        if p[3] == 0:
            out.append(p)
            continue
        visible += 1
        rgb = p[:3]
        if rgb in palette_set:
            out.append(p)
            continue
        mapped = nearest(rgb, palette, cache)
        changed += 1
        out.append((*mapped, p[3]))
    pct = 100.0 * changed / visible if visible else 0.0
    action = "would remap" if dry_run else "remapped"
    print(f"  {path.name}: {action} {changed}/{visible} visible px ({pct:.0f}%)")
    if not dry_run and changed:
        im.putdata(out)
        im.save(path)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--backdrop", required=True, type=Path,
                    help="zone ground backdrop PNG (the palette source)")
    ap.add_argument("props", nargs="+", type=Path, help="prop PNGs to lock")
    ap.add_argument("--dry-run", action="store_true",
                    help="report changes without writing")
    args = ap.parse_args()

    palette = backdrop_palette(args.backdrop)
    print(f"Palette: {len(palette)} colors from {args.backdrop.name}")
    for prop in args.props:
        if prop.resolve() == args.backdrop.resolve():
            continue  # never remap the palette source onto itself
        lock_file(prop, palette, set(palette), args.dry_run)


if __name__ == "__main__":
    main()
