---
name: "Session 2026-07-25 — T1 playground ground-only + matched props"
date: "2026-07-25"
tags: [session, art, level, backdrops]
branch: "feature/playground-ground-only-t1"
commits: []
---

# Session 2026-07-25 — T1 ground-only + matched props

## Focus

Abandon BG1 mismatched props. Ship hybrid **T1**: ground-only plate + props
made for that plate (v2 candidates) + footprint solids.

## What I did
*(newest first)*

- **Abandoned** `feature/playground-props-sprites` (local delete + remote delete).
- **Ground plate:** `playground_ground_painted.png` → production
  `playground_painted.png` (1280×816). Full-equipment paint backed up as
  `assets/reference/playground_painted_full_equipment.png`.
- **Props:** promoted `candidates/*_v2` → production swing/slide/roundabout/
  totem/duck/trees (legacy copies under `props/_pre_t1_legacy/`).
- **Scene:** y-sorted prop StaticBody2D under `World` with sprites + footprints;
  lottery remains on `WorldSolids`.
- Palette-lock props to the new ground plate.
- GUT: T1 prop presence tests.

## Why this should fit better than BG1

v2 props were generated against the **same ground plate** (2026-06-13 rework:
low top-down + backdrop crop). Equipment is **not** drawn into the ground image.

## Human gate

F5 playground: style match ground↔props; y-sort; collision; no double equipment
ghosts from the old full paint.

## Related

- [[research/2026-07-25-sorceress-tileset-forge-eval]] (T1 path)
- [[art/prop-coherence]] ground-only rule
