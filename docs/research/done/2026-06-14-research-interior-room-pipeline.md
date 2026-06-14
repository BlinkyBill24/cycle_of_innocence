---
name: "2026-06-14-research-interior-room-pipeline"
date: 2026-06-14
source: "web (pixellab.ai/docs, Godot 4.x docs, ComfyUI/ControlNet docs, Saint11 / Lospec / Midjourney docs) + existing project canon"
prompt: "Can Grok/PixelLab generate full interior rooms with consistent style + perspective + tile size + resolution across many rooms, or should interiors be assembled from tiles/props? The dev wants to ship generated full-room images directly and will build whatever tooling it takes; worst pains are perspective/projection drift and tile-grid/resolution mismatch."
status: integrated
tags: [research, art, pipeline, pixellab, godot, projection, tilemap]
---

# Interior room pipeline — ship-direct vs tiles vs hybrid

## Question / context
Generated full-room images (Grok/Aurora, PixelLab) drift in projection and don't align to the 32px grid; PixelLab text prompts alone can't enforce style/size/perspective. Decision needed: ship AI-generated full rooms directly (A), assemble from tiles+props (B), or a hybrid. Stated goal is A; willing to build real tooling. Worst pains: perspective drift + grid/resolution mismatch.

## Bottom line
**Build the HYBRID; abandon pure ship-direct.** Generate each room as a single **flat-lit floor+wall backdrop only**, then hand-author collision, `LightOccluder2D`, and y-sortable / animated prop sprites as separate layers on top — the same pattern already used for exterior buildings. Pure ship-direct breaks three locked systems at once: player y-sort behind furniture, runtime per-wall shadow occlusion, and 32-grid discipline over a large canvas. `[training knowledge + verified, see below]`

## Findings

### Why pure ship-direct (A) fails the locked constraints
- **Y-sort is impossible in one baked image.** Godot draws a `Sprite2D` as one item at one depth, so the player can only render entirely in front of or behind the whole room — never legs-behind-table / head-above. The only fix is to cut occluding furniture out and re-add it as separate y-sorted sprites — which *is* the hybrid. `[training knowledge — Godot rendering model]`
- **Runtime wall shadows must be authored regardless.** In Godot 4.x, `LightOccluder2D` shadows always render on top of what they occlude; z-index / "show behind parent" / y-sort no longer reorder them (GitHub godot #78964). A flat baked image supplies no internal occlusion, so occluder polygons are hand-authored either way. `[verified 2026-06-14, github.com/godotengine/godot issue #78964]`
- **Animated props (fire, fog) can't live inside a baked PNG** — they're already separate `AnimatedSprite2D` nodes in this project. `[existing canon: FX-props session 2026-06-13]`
- **CanvasModulate + PointLight2D do still tint/light a flat baked image**, *but only if it's genuinely flat/neutral with no baked light*, and it reads "stickered" because a baked image has no normals or internal occlusion. `[training knowledge; mitigation: optional Sprite2D normal map]`

### What the tools can and cannot do (verified caps)
- **PixelLab camera/projection control is explicitly weak.** Docs: the view "weakly controls the height of the camera"; options are `none` / `low top-down` (~20°) / `high top-down` (~35°). `[verified 2026-06-14, pixellab.ai/docs/options/guidance]` — matches the project's own "view weakly controls" note.
- **PixelLab's structural lock (Image-to-image depth) is a PROP tool, not a room tool** — canvas capped ~**180×180 px** (tier 2+; 128 free / 160 tier 1). Way too small for a room. `depth_strength` controls how much the model copies the reference depth. `[verified 2026-06-14, pixellab.ai/docs]`
- **PixelLab's biggest single canvas fits ONE screen-room, not a big room:** PixFlux Create M-XL caps ~400×400 (tier 2+); Pro "Create S-L/S-XL" reaches **512×512 square or 688×384 @16:9** ≈ 16×12 / 21×12 tiles at 32px. Beyond that → stitch or external pipeline. `[verified 2026-06-14, pixellab.ai/docs/tools]`
- **PixelLab Pro S-L palette:** no force-palette toggle (palette only via Style Image), so the external PIL palette-lock stays mandatory for Pro outputs. PixFlux/Map/depth do expose Target Palette + "Limit colors" / "Force colors". `[verified 2026-06-14, pixellab.ai/docs/options/color]`

### Consistency levers, ranked by power
1. **Structural control image = the only reliable PERSPECTIVE lock.** A Blender greybox rendered with an **orthographic** camera at the canon ~20° oblique → fed to PixelLab depth-img2img (props) or external **ComfyUI ControlNet Depth (~0.6) + MLSD** (full-room backdrops; MLSD keeps wall lines straight / non-converging). `[training knowledge + verified ControlNet/ComfyUI docs 2026-06-14]`
2. **Fixed canvas at multiples of 32 + nearest-neighbor downscale + grid-snap = the only reliable GRID lock.** Generate at N×32, downscale NN only (never bilinear/bicubic — Saint11), de-AI with a grid-snap/quantize tool (proper-pixel-art, Pixel It, Scenario Pixel Snapper), then PIL palette-lock. Even Retro Diffusion post-processes with downscale + quantize. `[verified 2026-06-14, Saint11 / Lospec / tool docs]`
3. **Style reference / IP-adapter / LoRA = STYLE lock only** (not geometry/grid). PixelLab Pro accepts up to 4 reference images + a Style Image ("color palette, outline, detail, shading"). A self-trained LoRA on ~20–40 own palette-locked canon-angle assets biases an external SD pipeline to house style. `[verified 2026-06-14, pixellab.ai/docs/tools/consistent-style; LoRA = training knowledge]`
4. **Seed locking = weakest.** Anchors composition for identical prompts only; doesn't survive prompt/model changes. Midjourney's own docs: seeds "have the least impact" and "can't … bookmark a specific style … across different prompts." Use for A/B iteration only. `[verified 2026-06-14, Midjourney docs]`

### Grid/resolution discipline (the second-worst pain)
Generate larger than target → **nearest-neighbor** downscale → grid-snap/quantize → Aseprite cleanup (scriptable) → PIL palette-lock as the deterministic final gate. Integer multiples only; never mix >2 resolutions (Saint11). If grid fidelity stays the dominant pain, **Retro Diffusion** (FLUX-based, hard grid alignment, fixed 32/64 grids, palette control, ControlNet-like + LoRA, Aseprite ext + API) is the strongest specialized supplement to PixelLab. `[verified 2026-06-14]`

## Maps to existing systems
- **Exterior-buildings pattern is already the hybrid** (baked worn-foundation backdrop + separately-authored StaticBody2D + runtime lights) → interiors reuse it wholesale; no new architecture. `[existing canon]`
- **ZoneRoot / GroundBackdrop + camera clamp** → the room backdrop slots in as the interior `GroundBackdrop`; camera clamp already keys off it.
- **CanvasModulate + PointLight2D + LightOccluder2D dread stack** → unchanged; requires the room to stay a scene with separate light/occluder/collision layers (i.e. *requires* hybrid, not baked).
- **palette_lock.py + QA gate (ratio table)** → unchanged final gate; extend the gate script to also check palette conformance on backdrops.
- **PixelLab create_map_object + depth-img2img prop recipe** → unchanged; this research only adds the *room backdrop* layer above it and the greybox/ComfyUI option for backdrops too big for the 180px depth cap.
- **Flat-neutral-light rule (rule 2)** → the basement_style_anchor.png FAILS this (baked lantern pool + floor gradient + drop shadows) and mixes projections (near-90° floor vs oblique props); usable as mood/contents only, NOT as a style/depth reference. `[flag]`

## Filter (story / companion / horror / replay)
Passes. The hybrid is the *only* path that preserves the runtime per-room dread tint (horror beat), keeps rooms as lived-in y-sortable spaces the player moves through behind furniture (companion/exploration), and keeps recontext + animated FX per-room (replay). Pure ship-direct would *fail* the horror filter by killing the runtime dread-lighting system. Nothing to flag for removal.

## Recommendation
1. **Hybrid now; drop pure ship-direct.** Bake only flat-lit floor/wall backdrops; author all interactive/animated/occluding/y-sortable content as separate layers. Pure ship-direct only ever acceptable for a genuinely non-interactive room with zero pass-behind props (still author collision/occluders).
2. **PixelLab = prop/tile engine + at most single-screen backdrop engine**, never the room engine. Pro S-L backdrops require the external palette-lock.
3. **Build the Blender canon-angle orthographic greybox rig first** — cheapest, highest-leverage perspective lock; feeds both PixelLab depth-img2img and ComfyUI.
4. **Stand up ComfyUI Depth+MLSD ControlNet** when backdrop drift or the 180px depth cap blocks you; add a self-trained style LoRA only if style drift persists after ControlNet.
5. **One automated script:** downscale(NN) → grid-snap → palette-lock → QA-gate (projection ratios + palette), run on 100% of assets.
6. **Web export:** Compatibility renderer, shared prop/wall atlases, mid-size backdrops, let Godot do WebP; watch unique-PNG count (Godot 4.3 wasm ≈40 MB raw / ~5 MB Brotli baseline). `[verified 2026-06-14, Godot web-export docs]`

Minimum viable build order: Blender rig → downscale/snap/palette script → QA gate → Godot room-scene template. ComfyUI when the prop-depth cap bites; LoRA last.

## Sources
- PixelLab — guidance/camera (view "weakly controls"; 20°/35°): https://www.pixellab.ai/docs/options/guidance `[verified 2026-06-14]`
- PixelLab — color options (Limit/Force colors, Target Palette): https://www.pixellab.ai/docs/options/color `[verified 2026-06-14]`
- PixelLab — style references (Pro), S-L/S-XL canvas + reference images: https://www.pixellab.ai/docs/tools/consistent-style ; https://www.pixellab.ai/docs/tools/create-sl-image-pro `[verified 2026-06-14]`
- Godot — 2D lights/shadows, occluder ordering issue #78964; Web export size notes `[verified 2026-06-14, github.com/godotengine]`
- ControlNet / ComfyUI (Depth, MLSD), Stable-Diffusion-Art `[verified 2026-06-14]`
- Saint11 pixel-art scaling (NN only, integer multiples), Lospec Blender Toolkit, Retro Diffusion, proper-pixel-art / Scenario Pixel Snapper `[verified 2026-06-14]`
- Midjourney docs — seed limitations `[verified 2026-06-14]`
- Existing project canon: exterior-buildings hybrid, ZoneRoot/GroundBackdrop, dread stack, palette_lock.py, QA gate, FX-props session `[internal, not re-verified]`
