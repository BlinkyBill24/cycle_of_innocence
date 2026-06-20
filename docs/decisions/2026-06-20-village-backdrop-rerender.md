---
name: Painted backdrops vs re-render into the 32px register
date: 2026-06-20
tags: [decision, art, pipeline, backdrops, open]
status: proposed
branch: docs/research-pixel-pipeline
related: "[[art/prop-coherence]] · [[design/ai-production-setup]] · [[research/done/2026-06-20-pixel-art-pipeline-consistency]] · [[sessions/2026-06-11]] (backdrop direction lock)"
---

# Decision (OPEN) — keep painted backdrops, or re-render them into the pixel register?

**Status: proposed / unresolved.** Surfaced by the 2026-06-20 pixel-art pipeline
research, which conflicts with a standing lock. Per R7 the lock was **not**
edited; this record exists for the human to decide. Do not treat as accepted.

## The conflict
- **Locked position** ([[art/prop-coherence]], 2026-06-11 "backdrop art direction
  lock"): zones ship a **painted `GroundBackdrop` Sprite2D** (Grok ground-only,
  angle-neutral plan-view repaints) with the camera clamped to it; props are
  separate palette-locked 32px nodes on top. We currently ship
  `village_painted.png` and `playground_painted.png` this way, and the Hollow
  House quest (2026-06-19) just added a graybox door onto the painted village.
- **Research finding** ([[research/done/2026-06-20-pixel-art-pipeline-consistency]],
  `[verified 2026-06-20]` ordering): the painted map should be **re-rendered into
  the 32px register** — (1) flatten lighting/AO, (2) nearest-neighbor downsample
  to the 32-grid FIRST, (3) palette-quantize at the lowest resolution, (4)
  normalize outlines, (5) Aseprite cleanup — and assembled as **tiled prop scenes**
  (PixelLab `create_topdown_tileset`), **not** shipped as a baked image. The
  argument: one register everywhere prevents style jumps (story), and tiled
  construction is modular/recombinable (replay).

## Options
1. **Keep painted backdrops (status quo).** Lowest effort; the lock holds; the
   painted look is already shipped and coherent enough for the vertical slice.
   Risk: a register mismatch between painterly backdrops and 32px pixel props
   becomes more visible as real character/prop art lands.
2. **Re-render into the register + go tile-based.** Higher consistency ceiling and
   modular zones, but real work (palette/tooling Stage 1, then re-render every
   zone) and it reopens a deliberate lock. Camera-clamp + VillageState markers +
   eavesdrop/patrol/recontext placement (the load-bearing layout work
   prop-coherence calls out) must all survive the conversion.
3. **Hybrid / defer.** Keep painted backdrops for the slice; pilot a re-render on
   **one** zone (e.g. the village green) behind the master palette once Stage 1
   tooling exists, compare side-by-side, then decide. Lowest-regret.

## Recommendation (mine, non-binding)
**Option 3** — defer the reopening until the master-palette + palette-clamp
shader Stage 1 exists (it's the prerequisite either way), then pilot one zone.
Re-rendering all backdrops now is premature before the register is even locked,
and the slice doesn't need it. But this is the human's call — the lock is yours
to reopen.

## If accepted, it would touch
- [[art/prop-coherence]] "backdrop direction lock" (Grok ground-only repaints),
  the camera-clamp invariant docs, and the `ai-production-setup` tiles row.
- A re-render pass per zone + tileset authoring; preserve all gameplay markers.

## Lookback
- Did the register mismatch actually read as a problem in playtest, or was the
  painted-backdrop coherence fine through the slice?
