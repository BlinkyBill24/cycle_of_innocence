---
name: pixel-art-pipeline-consistency
date: 2026-06-20
source: Claude Opus 4.8 + extended web research
prompt: >
  Research a consistency-first pixel-art production pipeline for a solo Godot 4.4
  (typed GDScript, web/HTML5 export, 32x32, low-top-down ~20 deg canon) top-down
  horror RPG. Converge all assets on a single high-res pixel-art register
  (cottage-interior look: clean cel shading, single-source warm/cold lantern
  lighting, ALttP-adjacent). Cover (1) exteriors/interiors as tiled prop scenes
  + re-rendering an existing painted village map into the register, (2) consistent
  32px multi-directional animated characters and how to stop head/volume drift,
  (3) the correct role of Grok Imagine (+ Projects) vs PixelLab, (4) a tool-agnostic
  style-lock protocol incl. a WebGL2-safe Godot palette-clamp shader. Respect locked
  constraints; map to the four-pillar filter (story/companion/horror/replay);
  flag uncertain or outdated info.
status: integrated
integrated: 2026-06-20 (branch docs/research-pixel-pipeline) — see integration log at foot
---

# Consistency-First Pixel-Art Production Pipeline

## Summary

- Make **PixelLab the single canonical sprite/tileset/prop engine and demote Grok Imagine to concept-only.** PixelLab natively matches the locked spec — its `view` parameter has a "low top-down" option documented as "Looking down at approximately a 20 degree angle" (vs "high top-down... approximately a 35 degree angle"), it outputs 4/8-direction characters and 32x32 Wang tilesets with transparent props, and it has a real reference/style-lock pipeline. `[verified 2026-06-20]`
- **Consistency comes from minimizing generators and locking one master style reference + master palette, not from better prompting.** Every asset should pass through one PixelLab style reference and one Godot-side palette-clamp/quantize shader (WebGL2-safe). `[training knowledge]`
- **Exteriors can become tiled prop scenes** via PixelLab `create_topdown_tileset` (Wang) + `create_map_object` at `view="low top-down"`, or a ComfyUI circular-padding seamless pipeline; the existing painted village map should be re-rendered into the register via downsample-to-grid + palette quantization, not shipped as a baked image. `[verified 2026-06-20]`

## Pillar 1 — Exteriors & Interiors as Tiled Prop Scenes

**PixelLab path (recommended primary).** `[verified 2026-06-20]`
- `create_topdown_tileset` generates a 16-tile Wang/corner-based set for seamless terrain transitions; `tile_size` supports 32x32; `transition_size` controls blend sharpness (0=sharp, 0.25=medium, 0.5=wide). Chain terrains with `base_tile_ids`.
- `create_map_object` produces discrete transparent-background props that can style-match an existing map via `background_image`. **CRITICAL: its `view` parameter defaults to "high top-down" — override to "low top-down" on every call** (this is exactly the Rule 5 / CANON_VIEW issue already in the vault).
- The "Create tileset" tool exports Wang, dual-grid 15-tile, and 3x3 formats. PixelLab also ships an MCP server (HTTP, bearer-token) so a coding assistant can generate tilesets and write the Godot import code directly.

**ComfyUI / A1111 seamless path (advanced / fallback).** `[verified 2026-06-20]`
Use circular-padding seamless tiling — ComfyUI-seamless-tiling ("Seamless Tile" node between loader and samplers + "Make Circular VAE"), or ComfyUI_Seamless_Patten's SeamlessKSampler/SeamlessVae, which switch Conv2d `padding_mode` to 'circular'. Note: the A1111 "Tiling" checkbox forces seamless wrap; ControlNet Tile is structural guidance/upscaling, NOT a seamless switch by itself — combine it with the Tiling setting. Verify seams with an Offset Image node.

**Retro Diffusion path (palette-strict alternative).** `[verified 2026-06-20]`
RD Tile creates tilesets with smart material transitions; RD Plus supports a `topdown_map` style with `tile_x`/`tile_y` seamless flags; all support uploading a limited palette image to lock colors plus one-click background removal. Pricing (Astropulse itch.io): full Aseprite extension $65, Lite $20, "No subscriptions and no credits required, just a flat upfront price." **Caveat:** the local Aseprite extension does NOT include animation generation — 4-direction animation requires the Retro Diffusion website/API (also on Replicate as `rd-tile`/`rd-plus`/`rd-animation`).

**Re-rendering the painted village map into the register.** `[verified 2026-06-20]` (ordering), `[training knowledge]` (step specifics)
(1) Boost contrast and flatten lighting/AO in the source; (2) nearest-neighbor downsample to the 32px grid FIRST; (3) enforce the master palette at the lowest resolution (quantization error is minimized there); (4) normalize outlines; (5) clean up in Aseprite. The "downsample first, THEN palette-quantize" ordering is confirmed by current ComfyUI pixel-art guides and the SD-piXL research (arXiv 2410.06236) — color-correcting at full resolution produces mush. Aseprite supports downsample-for-pixel-art and palette-aware reduction (median-cut/k-means/octree, optional Floyd-Steinberg dithering).

## Pillar 2 — Characters & Animation

**Strongest consistency-per-effort path: PixelLab character pipeline driven by a clean orthographic turnaround, NOT a single painted Grok concept.** `[verified 2026-06-20]` (features), `[training knowledge]` (ranking)
- `create_character` with `n_directions=4` or `8` and `view="low top-down"`. 4-direction = south/west/east/north; processing ~2-3 min (4-dir), 3-5 min (8-dir). Max rotation resolution 128x128/frame.
- **Stop head/volume drift:** PixelLab's skeleton animation tool has a "fixed head -> always" advanced option that copies the reference head across frames. Use the Rotate tool from a south-facing reference and regenerate other directions at 45 deg increments, updating the reference after each step (docs warn errors accumulate — check each step).
- **Feed a clean orthographic turnaround (front/side/back) as the style/reference image rather than a painterly concept — this is the single biggest lever against drift.** Reinforced by PixelLab's "Create images from style references (Pro)" and "Animation to animation" (set a good frame as reference).
- A hand-cleanup pass in Aseprite for volume consistency is non-negotiable for the last 10-15%. `[training knowledge]`

**Consistency backbone alternative — Universal LPC Spritesheet Generator.** `[verified 2026-06-20]`
Free, web-based; generates 4-direction LPC-standard walk/slash/thrust/cast/shoot/hurt from a shared skeleton. Licensing: dual CC-BY-SA 3.0 / GPL 3.0 (some assets OGA-BY/CC0) — commercial-usable but requires attribution and care with the GPL/DRM clause for closed storefronts. Gives a perfectly consistent skeleton you can re-skin into the register via the palette clamp.

**Diffusion alternatives (lower consistency-per-effort, not recommended as primary).** `[verified 2026-06-20]`
AnimateDiff + OpenPose/ControlNet can drive sprite frames, but "Sprite Sheet Diffusion: Generate Game Character for Animation" (Hsieh, Zhang & Yan, arXiv:2412.03685, Dec 2024 / rev. Mar 2025; 156 reference/pose/target pairs across 20 action sequences of 5 characters) confirms pose estimators struggle with game-sprite proportions and frames need manual annotation — high effort, inconsistent.

**Verdict:** PixelLab character + skeleton animation with a clean turnaround reference = best consistency-per-effort; LPC = strongest free consistency backbone; diffusion-pose pipelines = last resort. `[training knowledge]`

## Pillar 3 — Grok Heavy + Imagine "Projects" Role

**Recommended division of labor:** Grok = concept/mood/reference-art generator ONLY (style-anchor draft). PixelLab = canonical sprite/tileset/prop/animation engine. Optional ComfyUI/Retro Diffusion = seamless-tiling or palette-strict specialist tasks. `[training knowledge]`

Grok's limitations are confirmed: `[verified 2026-06-20]`
- Still-image generation/editing supports only up to 3 reference images (the "up to 7 reference images" feature is VIDEO-only — Reference-to-Video).
- "Projects" is described in xAI's release notes as "Save and revisit past Agent Mode sessions" — an organizational container, NOT a cross-image style-consistency engine.
- No official xAI documentation confirms transparent-background (alpha) PNG sprite output; only third-party API wrappers (Runware, Atlas Cloud) mention PNG/WEBP alpha at the container level, which is generic format boilerplate, not proof the model renders clean cutouts. Direct user testing (Kris Schnee on X) reports Grok fails to produce evenly-spaced, non-overlapping sprite sheets on a featureless/transparent background.

So the style anchor of record should be a **PixelLab style reference sheet + master palette**, with Grok kept strictly upstream for fast horror-mood ideation, then converted to pixel via PixelLab's image-to-pixel tools.

## Pillar 4 — Style-Lock Protocol

A repeatable, tool-agnostic protocol: `[training knowledge]` (protocol), `[verified 2026-06-20]` (shader/web-export facts)
1. **Master palette:** fixed N-color palette (e.g., 32 or 48) as a palette PNG. Feed it to Retro Diffusion (palette image), PixelLab (forced palette where supported), and the Godot runtime shader.
2. **Master lighting/shading spec:** single-source warm/cold lantern model; document light direction, cel-shading band count, shadow color, and "flat-lit baseline + runtime dread layered on." Generate flat-lit; add darkness/light at runtime via CanvasModulate + Light2D + LightOccluder2D.
3. **Reference-sheet discipline:** one canonical character turnaround + one tile/material reference sheet, reused as the style image for every generation.
4. **Godot-side post-process unifier (WebGL2-safe):** a canvas_item palette-clamp/quantization shader applied at import (bake) or runtime to snap any mismatched asset to the master palette. Avoid dynamic loops with variable bounds; the Compatibility renderer used for web export supports the fixed-iteration palette-swap approach. Base on KoBeWi's MIT palette-swap shader or godotshaders.com quantization shaders.

## Architecture cross-check — Godot #78964

Issue #78964 is real and confirmed open. `[verified 2026-06-20]` Filed against Godot 4.0.3: when using a LightOccluder2D or a TileSet occlusion layer, shadows always render on top of what they occlude, and the occluder can no longer be moved behind its parent via "Show behind parent", z-index, y-sorting, or tree order. This genuinely breaks ship-direct full-room AI images and justifies the separate backdrop / occluder / y-sortable-prop layers already in the vault. Workaround exists: set the occluder polygon's cull mode so shadows cast outward only (Issue #102160 reports resolving self-shadowing "by applying a clockwise cull mode"; correct direction depends on polygon winding — Catlike Coding's true-top-down tutorial uses counter-clockwise). The layered architecture remains the cleanest overall solution.

## Four-Pillar Filter Mapping

- **Story:** re-rendered coherent exteriors + interiors create a believable contiguous world; a single register prevents immersion-breaking style jumps.
- **Companion arc:** PixelLab character + skeleton consistency (fixed-head=always) keeps the companion reading as the same character across all directions/animations/emotional beats.
- **Horror beat:** flat-lit assets + runtime lantern lighting/LightOccluder2D shadows make dread dynamic and controllable, not painted-in; Grok concept art accelerates horror-mood exploration upstream.
- **Replay value:** tiled prop-scene construction (vs baked images) makes rooms modular/recombinable and keeps 32-grid discipline, enabling layout variation and faster content expansion.

## Suggested Rollout (engineering judgment, not vendor claims) `[training knowledge]`

**Stage 1 — lock the register (~week 1):** author master palette PNG + one character turnaround + one tile/material reference sheet in Aseprite; stand up the palette-clamp shader and confirm it runs in an actual web export (Compatibility renderer) before relying on it. Fallback: if the shader artifacts on web or tanks frame rate, bake palette quantization offline (Aseprite/ComfyUI) at import instead of runtime.

**Stage 2 — tiles & exteriors (weeks 2-3):** PixelLab `create_topdown_tileset` (tile_size 32, view="low top-down") for floors/walls; `create_map_object` for props (override view!). Re-render the village: downsample-to-grid -> palette quantize -> Aseprite cleanup; do NOT ship the painted image. Fallback: if PixelLab seams are unacceptable, use ComfyUI circular-padding or RD Tile with the master palette; if AI can't hold the grid/angle, hand-author key tiles and use AI only for variations.

**Stage 3 — characters (weeks 3-5):** PixelLab `create_character` (4-dir first) from the clean turnaround; skeleton animation with fixed-head=always; Aseprite cleanup. Fallback: if drift persists, move to LPC skeleton + re-skin.

**Stage 4 — integration discipline (ongoing):** every asset, regardless of origin, passes through the palette clamp and a 32-grid alignment check before entering the game; keep Grok strictly upstream of PixelLab.

## Caveats & Uncertainty

- **AI tools change fast.** PixelLab tool names/parameters (`create_topdown_tileset`, `view` defaults) and Grok Imagine capabilities are current as of mid-2026 but may shift; re-verify the `view` default and transparency support before a production run.
- **Grok transparency is unverified, not confirmed-absent.** Official xAI docs are silent on alpha output; third-party wrapper claims are generic boilerplate. Treat Grok as opaque-only for safety.
- **LPC licensing (CC-BY-SA / GPL)** requires attribution and has a DRM-clause wrinkle for encrypted storefronts; prefer CC0/OGA-BY assets if shipping on Steam/iOS to avoid ambiguity.
- **Web-export shader caveat:** avoid dynamic loops; test the palette shader in a real HTML5 build early (Safari/WebGL2 quirks exist).
- **Single-source research.** This is one research pass (no second model corroboration), so nothing here is marked `[cross-model]`. `[verified 2026-06-20]` = confirmed from primary/official sources (PixelLab docs, xAI docs/release notes, the Godot issues, the arXiv paper, Retro Diffusion's itch listing, the ComfyUI seamless nodes). `[training knowledge]` = synthesized engineering judgment (the consistency-per-effort ranking and the stage timeline).

## Sources

- PixelLab API / docs — https://www.pixellab.ai/pixellab-api
- PixelLab tileset generator skill — https://lobehub.com/skills/cautiouskurns-game-template-pixellab-tileset-generator
- xAI Imagine docs — https://docs.x.ai/developers/model-capabilities/imagine
- ComfyUI seamless tiling node — https://www.runcomfy.com/comfyui-nodes/ComfyUI-seamless-tiling
- Retro Diffusion on Replicate — https://replicate.com/blog/retro-diffusions-pixel-art-models-are-now-on-replicate
- Universal LPC Spritesheet Generator — https://github.com/liberatedpixelcup/Universal-LPC-Spritesheet-Character-Generator
- Sprite Sheet Diffusion — arXiv:2412.03685
- SD-piXL — arXiv:2410.06236
- Godot issue #78964 (LightOccluder2D shadow z-order) and #102160 (cull-mode workaround) — github.com/godotengine/godot/issues

---

## Librarian integration log (2026-06-20, branch `docs/research-pixel-pipeline`)

Processed per `docs/research/README.md` (propose-first; locked decisions flagged, not edited). Findings mapped:

- **Confirmatory (no change):** Rule 5 / CANON_VIEW `low top-down` override, PixelLab-for-characters/variants, flat-lit + runtime lighting, the layered backdrop/occluder/y-sort architecture (Godot **#78964** *validates* it).
- **`docs/art/prop-coherence.md`** — Rule 1: added runtime palette-clamp shader option + web-export caveat (complements `tools/palette_lock.py`). Rule 4: added the #78964 / #102160 cull-mode workaround note. Header: pointer to the new backdrop decision (below).
- **`docs/design/ai-production-setup.md`** — "static tiles/icons" row: PixelLab `create_topdown_tileset` now primary, RD palette-strict fallback; RD **animation caveat** (Aseprite ext is static-only); LPC licensing red-line added.
- **`docs/decisions/2026-06-10-sprite-tool-pixellab.md`** — added a drift-avoidance workflow note (fixed-head=always, clean turnaround reference). *Decision not reopened — implementation detail only.*
- **`docs/ideas.md`** — LPC consistency backbone (+ licensing flag), master-palette + style-lock protocol (Stage-1), ComfyUI circular-padding seamless fallback.
- **FLAGGED → new decision** `docs/decisions/2026-06-20-village-backdrop-rerender.md`: the "re-render the painted village map into the register vs keep the painted-backdrop lock" tension. The locked backdrop direction was **not** edited; the conflict is an open decision for the human.
