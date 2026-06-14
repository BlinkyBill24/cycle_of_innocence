---
name: Interior art + dressing pass (3 interiors)
date: 2026-06-14
tags: [decision, art, interiors, pipeline]
status: in-progress
branch: feature/interior-art
related: "[[art/interior-design-kit]] · [[mechanics/accessible-interiors]] · [[design/hollow-house-quest]] · [[art/prop-coherence]]"
---

# Decision — Interior art + dressing pass

Replace graybox with real art + final layout for the three built interiors
(`cottage_ground`, `cottage_basement`, `hollow_house`). **Art + dressing only —
no mechanics changes, no moving gameplay nodes unflagged.** Source: `/goal`
2026-06-14, grounded in [[art/interior-design-kit]].

## Context (verified from the scenes)
- Each floor = **one `GroundBackdrop` Sprite2D** (the camera-clamp source) + props
  as separate nodes ([[mechanics/accessible-interiors]]). Rooms: cottage ~384×256px
  (12×8 tiles), hollow_house ~470×310px (~14×9) with an interior partition
  (hub + left whisper-room + right ledger-room behind `GatedDoor`).
- Gameplay nodes already placed: spawns, `ExitDoor`/`StairsDown`/`StairsUp`,
  `MartaSpot` (cottage_ground), recontext groups, whisper/ledger/dread nodes
  (hollow). **Art hangs on these — keep them.**
- PixelLab: active sub (Tier 2), 4322 generations left — generation is cheap
  relative to the budget.
- Carried-over uncommitted edits to `hollow_house.tscn` are **Godot 4.4
  re-saves** (UID assignment + default-value pruning, all verified == script
  defaults) — non-destructive, kept.

## Decision — pipeline reconciliation
The goal's `create_topdown_tileset` is the **generation method**; the deliverable
stays a **single composed backdrop PNG per floor** that replaces the placeholder —
this keeps the locked Sprite2D-backdrop + camera-clamp architecture. Walls
(back wall 2–3 tiles, sides, doorway frame) are generated as map objects and
**baked into the composed backdrop**, so the room still reads as one Sprite2D.
Props sit on top as separate nodes; stairs are an **authored set-piece sprite on
a layer above the player** (not tiled, not baked).

**Palette source for `palette_lock`**: each scene's composed floor backdrop PNG
(its own 48-color palette). Props for that scene lock to that backdrop, per
[[art/prop-coherence]] rule 1. Warm cottage and cold hollow get **different**
palettes — the shared neutral tileset gives geometry; per-scene recolor gives
temperature.

## Pipeline contract (locked, from goal)
32×32 · low top-down · palette-locked · **flat/neutral baked light**. Bake NO
hearth glow / dread tint / directional shadow — dread is runtime: `CanvasModulate`
(per-floor, keyed to `dread_baseline`) + `PointLight2D` (radial gradient, shadow
None/Fast) + occluders. Undefined look (hollow register, stairs) → **Grok concept
FIRST**, then PixelLab. Every gen → trim → `palette_lock` → gate before it enters
a scene.

## Staged plan
- **Step 0 — context + foundation** *(done)*: read scenes/doc/tools; balance
  checked; Grok concept pass launched (hollow register + stairs); shared floor
  tileset `d569549b` generating.
- **Step 1 — shared tileset + lighting contract**: assemble floor tileset → compose
  per-scene backdrops (floor + baked walls) → palette_lock → gate. Confirm the
  Godot light stack renders crisp (filter None); tune dread via `CanvasModulate`
  alpha, **not** by repainting sprites. Add the warm light stack to `cottage_ground`
  (currently none): warm `PointLight2D` at the hearth, optional faint-warm
  `CanvasModulate`.
- **Step 2 — props & stairs** *(fan out: 1 subagent per scene once Step 1 lands)*:
  per scene `create_map_object` with a crop of that floor's backdrop as
  `background_image` → trim → palette_lock → gate; variants via
  `create_object_state` (never fresh); stairs set-pieces via image-to-image depth.
- **Step 3 — layout + wire**: place props on the existing node graph, keep
  `marker_marta` sightlines clear, wire each "wrong" prop to a recontext node,
  set the safe→tense→wrong gradient (basement gets exactly ONE off-note).

## De-risking (because agents are runtime-blind)
- **`cottage_ground` first, end-to-end** (the "beautiful room" — brief's ceiling
  demo): generate → compose → wire → **human F5 checkpoint** before scaling to the
  other two. Validates the blind pipeline on one scene cheaply.
- Acceptance is human-judged at F5: reads at game zoom, survives `CanvasModulate`
  without muddying, stairs read as traversable behind railings, no baked
  light/shadow fighting runtime dread. Collision/dressing may be flagged for the
  user.

## Out of scope
No mechanics changes; no moving gameplay nodes (flag if needed); no baked
lighting; no tiled stairs; no interiors beyond these three.
