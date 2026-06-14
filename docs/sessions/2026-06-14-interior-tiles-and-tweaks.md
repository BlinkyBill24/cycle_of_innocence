---
name: Cottage table swap, furniture moves, reference-matched floor/wall tiles
date: 2026-06-14
branch: feature/interior-tiles-and-tweaks
tags: [session, art, interiors, tiles]
---

# 2026-06-14 — Cottage tiles + tweaks

## What I did
- **Committed the user's furniture rearrangement** in `cottage_ground.tscn`
  (positions only; back-wall props raised, dining nook/chests/plants moved).
- **Swapped the table** to PixelLab object `c8dac2f6` (the user-preferred
  style-ref / `background_image` floor-lock version), palette-locked.
- **Floor + wall tiles per the cottage anchor** (`style_palette_angle_anchor.jpeg`):
  orange running-bond **brick floor** (`floor_brick.png`, seamless 32px) + grey-tan
  **stone-brick back wall in a timber frame** (`wall_stone_brick.png`), wood side
  posts, dado + doorway. Palette sampled from the anchor; walls procedural
  (PixelLab still returns near-empty for seamless walls). Recomposed
  `cottage_ground_floor.png` (480×320, camera-clamp/coords preserved). Reads well
  with the user's layout; scene loads, import clean.

## Notes / follow-ups
- A PixelLab brick floor tileset (`be980b5e`) was fired but the procedural floor
  shipped instead (faster, palette-exact); swap to the tileset if a more organic
  floor is wanted.
- **Basement + hollow still need their own floor/wall tiles** per their anchors
  (`basement_style_anchor.png` cold stone; `hollow_house_register_concept.png`
  desaturated) — not started; offered.
- Pre-existing floating edits (`campfire`/`fog`/`playground`/`village_green` UID
  re-saves) left uncommitted — not part of the furniture work.
