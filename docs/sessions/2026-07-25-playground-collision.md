---
name: "Session 2026-07-25 — Playground solid props (C1)"
date: "2026-07-25"
tags: [session, level, collision]
branch: "feature/playground-collision"
commits: []
---

# Session 2026-07-25 — Playground solid props

## Focus

Bite C1: stop Rowan walking through playground equipment and key props.

## What I did
*(newest first)*

- `WorldSolids` StaticBody2D (layer 1): roundabout, slide, swing, frame,
  cult totem base, lottery post — **footprint** shapes, not full art height.
- Campfire radius 8→12; explicit `collision_layer = 1` on Borders + Campfire.
- Surface zones / forage / dig left as Area2D (walkable).
- GUT: `tests/test_playground_collision.gd`.

## Decisions made

- None (implements PM plan C1). Footprints hand-authored against surface-zone
  anchors; human F5 may nudge positions.

## Next session

- Human F5: bounce off equipment; still reach hideout, dig, berries, transitions.
- C2: village building footprint nudge.

## Related

- PM plan: backdrop + solids (chat 2026-07-25)
