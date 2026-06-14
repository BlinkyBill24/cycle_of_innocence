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

## Next
- Human F5: does the enriched cottage read; treasure-chest gold acceptable; rug
  layering correct in-engine.
