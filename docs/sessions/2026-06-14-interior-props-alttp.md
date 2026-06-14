---
name: ALttP canon prop vocabulary + cottage_ground enrichment
date: 2026-06-14
branch: feature/interior-props-alttp
tags: [session, art, interiors, pixellab]
---

# 2026-06-14 — ALttP canon prop vocabulary

User supplied ready-to-copy PixelLab prompts (ALttP house-interior reference set).
Generated, processed, and wired into the cottage_ground reference scene.

## What I did
- **9 canon props** via `create_map_object` (low top-down, flat shading, selective
  outline) → trim → palette-lock to the cottage 48-color palette → gate sheet:
  bed, table, stool, rug (canon **upgrades** of the first-pass versions),
  storage_chest, treasure_chest, shelf_pottery, wall_rack, door. Higher fidelity
  + cleaner canon (top+front visible, straight verticals) than the first batch.
- **Floor tileset** `b54fb251` (warm horizontal planks + worn variant) → seamless
  tile saved as `floor_plank.png` (reusable for future interiors).
- **Wall paneling**: PixelLab returned near-empty (38×16) — confirms walls stay
  procedural (consistent with the hollow agent's experience).
- **cottage_ground enriched**: upgrades swapped in by filename; added storage chest
  (by the bed), treasure chest (**bottom-right corner**, ALttP canon), pottery
  shelf + bottle rack on the back wall, paneled front door in the doorway.
- **y-sort bug fixed**: the rug (parent `World`, y=34) sorted *in front of* the
  table/stools (y≈28) and covered them — also present in the shipped scene. Moved
  the rug to a non-y-sorted `FloorDecals` node below `World` so it draws under
  furniture. Re-verified via composite preview.
- Documented prompts in [[art/imagine-prompts]] (R4). Suite green (882); scene
  instantiates headless (World 18, FloorDecals 1).

## Flags
- Treasure-chest gold muted toward brass by the cottage palette lock (no pure gold
  in palette) — still reads as ornate metal trim; exempt it if pure gold wanted.
- New props have no collision (assets/dressing pass) — editor/user.
- The canon floor tileset is saved but `cottage_ground` still uses its original
  composed floor; swap in `floor_plank.png` if a cleaner long-plank look is wanted.

## Shared-prefix A/B + canon learning (follow-up)
- I had NOT pasted the user's full canon prefix into the prop prompts (condensed
  instead). User asked to A/B it. **A/B 2026-06-14**: 3 props regenerated with the
  full ~900-char prefix → table 15×17, treasure chest 6×8 (near-empty), rug
  rendered a whole room. Long prose **breaks** PixelLab generation.
- Reconciled with inbox research [[research/done/2026-06-14-research-prop-perspective-lock]]:
  prose can't pin geometry at all; the robust lever is a **reference image**
  (view + `background_image` crop), escalating vertical-heavy furniture to
  image-to-image depth. Amended [[art/prop-coherence]] workflow with both findings.
- **Flag**: the current committed interior props (incl. vertical-heavy table/
  wardrobe/shelf) were made description-only (the weaker path) — they read OK by
  eye + gate, but the canon-robust path for furniture is depth-i2i. Regenerate via
  depth-anchor if any fail the gate ratio. Not done now (props look acceptable).

## Tier-2 geometry-lock pass (user-directed: full vertical set + anchors)
- **Tooling reality**: PixelLab MCP has the style lever (`background_image`) but NO
  native image-to-image depth (web only). Substitute proven: canon grey-box → Grok
  `edit_image` structure-preserving img2img → bg-key → downscale → binarize alpha →
  `palette_lock`. 3-way table A/B confirmed style-ref drifts angle; grey-box→Grok
  locks it. Recorded in [[art/prop-coherence]] (tiered pipeline + empirical proof).
- **Cottage vertical set regenerated** (table, stool, wardrobe, shelf_pottery,
  hearth) via that pipeline — geometry canon-locked by hand-built grey-boxes.
  Wardrobe/shelf/hearth biggest upgrades. Same filenames → no scene edit. Suite
  green. Cottage anchor = `style_palette_angle_anchor.jpeg` (Grok, user-supplied).
- **Room anchors** (Grok): basement `basement_style_anchor.png` (new, cold stone
  cellar); hollow = existing `hollow_house_register_concept.png` (Grok moderation
  rejects abandoned/eerie phrasing). All three recorded in prop-coherence.

## Next
- Human F5: cottage reads; treasure-chest gold acceptable; rug layering in-engine.
- **Basement + hollow Tier-2 prop passes** using their anchors (same grey-box→Grok
  recipe) — not started; offered.
