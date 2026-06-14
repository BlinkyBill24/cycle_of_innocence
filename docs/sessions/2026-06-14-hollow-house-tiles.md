---
name: Hollow_house floor + wall tiles (completes 3-room tile pass)
date: 2026-06-14
branch: feature/hollow-house-tiles
tags: [session, art, interiors, tiles, horror]
---

# 2026-06-14 — Hollow_house tiles

Last of the three interior tile passes (per [[art/interior-design-kit]] hybrid
room pipeline; anchors are mood/palette refs only, backdrops rebuilt flat-lit).

## What I did
- Sampled the hollow register concept anchor: desaturated grey-green vertical-plank
  floor (`~82,90,77`) + cool grey-blue peeling walls (`~104,123,130`).
- Built reusable tiles `floor_plank_hollow.png` + `wall_plank_hollow.png` (flat-lit).
- Recomposed `hollow_house_floor.png` (480×320) with the interior **partition walls
  baked at the exact collision bands** (perimeter + vertical partition with the gate
  gap + horizontal partition with the doorway gap) and the **clean-dust-rectangle
  recontext beat** in the right room. Works with the existing hollow prop layout
  (broken cabinets, table/chairs, cobwebs, bowls, lone chair on the clean rectangle).
- Suite green (882); scene instantiates headless (18 root children).

## State — all 3 interior rooms now have reference-matched tiles
- cottage_ground: orange running-bond brick + stone/timber walls.
- cottage_basement: grey flagstone + running-bond stone blocks.
- hollow_house: desaturated grey-green planks + grey-blue partition walls.

Flat-lit throughout; runtime `CanvasModulate` + `PointLight2D` + occluders own mood.
