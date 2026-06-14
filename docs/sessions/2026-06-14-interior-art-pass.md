---
name: Interior art + dressing pass (cottage_ground, cottage_basement, hollow_house)
date: 2026-06-14
branch: feature/interior-art
tags: [session, art, interiors, pixellab, grok]
---

# 2026-06-14 — Interior art + dressing pass

Goal: replace graybox with real art + final layout for the three built interiors.
Plan: [[decisions/2026-06-14-interior-art-pass]]. Orchestrated with Claude
subagents (per user "claude agents") — pipelined behind a hard barrier (shared
floor/style before per-scene props).

## Outcome — all 3 interiors art-passed (committed)
- `cottage_ground` (457e5e0), `cottage_basement` + `hollow_house` (6be7e88).
- 31 props total, each trimmed + palette-locked to a per-scene unified ~48-color
  palette; 3 composed backdrops at exact sizes (camera-clamp + coords preserved);
  stairwell set-pieces; per-scene runtime lighting (CanvasModulate + PointLight2D
  + occluders). Flat-lit art; mood is runtime. Suite green (882 asserts), all
  three instantiate headless. **Collision for new props deferred to the editor/
  user pass** (assets only). Basement + hollow generated in parallel by two asset
  subagents (per "claude agents"); orchestrator wired + verified each scene.

## What I did
- **Context locked**: read all three scenes + [[mechanics/accessible-interiors]]
  + pipeline tools. Confirmed the carried-over `hollow_house.tscn` edits are
  non-destructive Godot 4.4 re-saves (every pruned property == script default).
- **PixelLab balance**: active sub, 4322 generations left — generation viable.
- **Grok concept pass** (background subagent) → `assets/reference/interiors/`:
  - `hollow_house_register_concept.png` — **strong, kept.** Desaturated
    grey/olive/cold-blue, overturned table+chairs, dust-sheet shape, broken
    bottle-cabinet, cobwebs, and the hero "clean rectangle in the dust + lone
    chair" absence beat. Doubles as a layout guide for hollow_house.
  - `stairs_setpiece_concept.png` — **off-canon, regenerate in Step 2.** Came
    out 3/4 isometric (~40°) with baked directional shading; our canon is low
    top-down (~20°) + flat-lit. At 20° a *descending* stair is a compact
    stairwell opening (top-step edges + dark gap, ALttP-style), not a big iso
    staircase. Will redo as a compact set-piece.
- **Shared floor tileset** `create_topdown_tileset` (low top-down, flat shading,
  32px, plank floor + cracked variant) — id `d569549b`, generating.
- Wrote the staged plan ([[decisions/2026-06-14-interior-art-pass]]) and reconciled
  the goal's tileset step with the locked single-`GroundBackdrop` architecture:
  tileset is the generation method; deliverable is a composed backdrop PNG per
  floor.

## Next
- Assemble floor tileset → compose `cottage_ground` backdrop → palette_lock → gate.
- **`cottage_ground` end-to-end first** (brief's "beautiful room") → human F5
  checkpoint before scaling to basement + hollow_house.
- Regenerate stairs as a compact low-top-down stairwell set-piece.

## F5 checks for the human (agents are runtime-blind)
- Does each scene read at game zoom? Does the art survive `CanvasModulate`
  without muddying? Do stairs read as traversable behind railings? No baked
  light/shadow fighting runtime dread?
