---
name: "Research — art/audio/animation tooling assessment + prop-coherence plan (screenshot review, cross-checked vs Grok)"
date: 2026-06-12
source: "claude.ai bridge (Claude Fable 5): 4 build screenshots, PixelLab/Ludo docs verification via web, cross-review of a Grok response supplied by the user; grounded in docs/_compiled/ snapshots (post-round-3 refresh)"
prompt: "honest assessment whether i am using the right tooling for sounds, graphics, animations… are there AI tools that are able to create maps and villages that make sense or is this purely a manual job?"
status: integrated
---

# Art/Audio Tooling Assessment & Prop-Coherence Plan

## Verdict
The stack is right; the failure in the screenshots is a **compositing/workflow gap, not a tooling gap** — and the vault has already invented most of the cure. The Terranigma pass shipped prop-blending fixes (desaturation toward ground palette + procedural contact-shadow ellipses) and the backdrop lock established baked worn foundations for buildings; the screenshots show zones/captures where those mechanisms haven't landed yet. Both models reviewed (this one and Grok) reached the same diagnosis independently.

## Screenshot diagnosis (4 images, mixed vintages)
- **Image 1** carries the `[Progression Test]` label and the old tile pipeline (autotile path zigzags, uniform grass) — pre-backdrop vintage.
- **Images 1, 2, 4** still contain the **chapel courtyard ground decal** (lanterns/flower beds/paving/bench) — the Terranigma set-piece that the backdrop-lock decision explicitly killed alongside tile-variant "stickers". It reads as a pasted screenshot because it is one. Enforcement item, not a new finding.
- **Images 2/4** show the grey void above the backdrop: Camera2D limits aren't clamped to the backdrop rect (or the backdrop lacks bleed margin).
- **Image 2**: Rowan + Briar stand on top of the painted stone wall — missing StaticBody2D on a painted feature (editor-placement pass).
- **Cross-image**: cool violet-grey props (well, lamps, fences) on warm ochre ground; baked daylight highlights on the cottage inside night scenes; floating buildings (chapel, cottage, image-3 house) without foundations; door-height/scale drift between buildings; villager kid sprite at a different fidelity than the PixelLab characters; midday glow halo around Rowan (image 4) reads as a light left on.
- **Image 3 is the proof of concept**: painted road + relit props + PixelLab characters nearly cohere — the locked direction works where palette and light agree.
- Context: the **village zone is mid-conversion** ("placeholder ground atlases until renders land" per the village-green entry). The screenshots are that gap made visible, not a regression.

## Tooling verdicts
- **Characters/animation — PixelLab: keep, no change.** Rowan/Briar are the most consistent elements in all four shots; the v2/v3 animate-character pipeline, quirk poses, and cost profile are proven in the record.
- **Backdrops — Grok `edit_image` GROUND-ONLY repaint: keep.** Image 3 is the evidence.
- **Props — right vendor, wrong call.** `create-image-pixflux` generates context-blind (own palette/light/projection per call). Fix is map-aware generation + the existing blending mechanisms (below).
- **Audio — keep.** Hand-rolled AdaptiveAudio is canonical post-[[decisions/2026-06-12-adaptisound-rejected]]; the stem-alignment risk is compositional discipline, already queued as Next-arc 2 (one composition, stripped mixes). No better FOSS option for aligned stems found [training knowledge].

## Verified tool findings [verified 2026-06-12]
- **PixelLab `create_map_object`** (MCP/API): generates transparent map objects **with style matching against a supplied `background_image`** — width/height auto-detected from the background (pixellab.ai/mcp). This is the inpaint-then-crop workflow productized: feed a crop of the actual zone backdrop → prop inherits palette/light/projection, stays a transparent sprite for y-sort/collision. MCP is already registered (`claude mcp add pixellab`). **Caveat from our own record**: `create-tileset` reference-image params 500 server-side and the proven style path is `generate-with-style-v2`/bitforge — so smoke-test `create_map_object` with a real backdrop crop before building pipeline on it; fallback is style-v2 with the same crop.
- **PixelLab Create/Extend Map**: guided region inpainting (select tiles, rough sketch, inpaint, expand) — human-directed by design (pixellab.ai/docs/guides/map-tiles).
- **PixelLab Create Tileset**: Wang / dual-grid 15 / 3×3 exports with a **target-palette option** (pixellab.ai/docs/tools/create-tileset) — already in production here.
- **Field check on alternatives**: Ludo.ai does offer tilesets + style references among its asset types (ludo.ai), but nothing layout-level; Charmed tilemapgen is SD-based isometric dungeon tiles (wrong projection); generic web tileset generators (e.g. myaiart) duplicate what PixelLab already provides on a paid tier we own. **Conclusion: in mid-2026, AI map tooling is asset/tileset-level everywhere. Nothing one-shots a village that "makes sense."** Layout remains design work — and here it is load-bearing (VillageState routine markers, eavesdrop zone placement, Warden patrol readability, recontext groups).

## Cross-model review (Grok response, user-supplied)
**Convergent (independent agreement — treat as high-confidence):** compositing-not-tooling diagnosis; PixelLab and audio verdicts; "no fully automatic village AI — human taste for layout serving routines/suspicion/eavesdrops/recontext"; content-complete-zone-before-new-mechanics (already adopted as the Next-arcs scope rule). Grok's framing worth keeping: zones must read as *lived-in conspiracy spaces, not modular kitbash* — that is the replay-value stake.

**Adopted from Grok:**
1. **PROPS-ONLY `edit_image` diagnostic**: run one repaint pass on a real composited screenshot ("repaint the lantern/bench/well to match the ground lighting and palette") — the locked GROUND-ONLY pattern pointed at props, as a cheap visual target before regenerating anything. *Caveat*: re-cropping repainted props bakes scene light into the sprite — fine for zone-locked props, wrong for props shared across times of day (CanvasModulate owns time-of-day). Use as diagnostic/benchmark, not as the standing pipeline.
2. **Stem prompt direction**: wrong-pitched lullaby fragments as the tense-stem motif — consistent with [[mechanics/adaptive-audio]] and the bible's lullaby thread; fold into the Next-arc-2 ACE-Step prompts.
3. Grok referenced `place_village_props.py` / `preview_village_map.py` correctly — confirmed real in the record (repo-grounded, not hallucinated).

**Flagged — do not integrate as-is:**
1. **"Pre-baked ellipses" for shadows** partially contradicts the record: ellipses were *removed* on ≥96px sprites (they caused floating); current canon is procedural contact-shadow ellipses for small props + baked worn foundations for buildings. Keep the canon split.
2. **Ludo.ai / Leonardo.ai / Midjourney "tilemap export plugins"**: Ludo's actual capability is tileset/asset generation with style refs [verified 2026-06-12] — no "layered tile proposals" found; Leonardo/Midjourney first-party tilemap export does not exist to my knowledge [unverified — likely conflated with third-party slicers]. All three would add vendors to a **locked art lane** (Grok Imagine + PixelLab + Retro Diffusion static) without adding capability we lack. Reject without reopening the lock.
3. **Stale framing**: "toward the slice gate / hitting vertical slice" — slice shipped, post-slice queue complete; Grok's temporal grounding lagged the snapshots.
4. **"pixflux with style-ref already in use"**: untested claim; the record shows reference-image params 500ing on `create-tileset` with bitforge/style-v2 as the only proven style path. Treat pixflux style-ref as unknown until smoke-tested.

## Ordered fix plan (cheap → structural; *apply-existing* vs *new*)
1. *(enforce existing)* Remove the courtyard decal instances from all scenes — the decision already exists; this is cleanup.
2. *(new, trivial)* Clamp Camera2D limits to backdrop rects (or add bleed margin) — kills the grey void.
3. *(new rule)* **Palette hard-lock**: extract each zone backdrop's 48-color palette; force-quantize every prop to it (ImageMagick `-remap` / Aseprite CLI in `tools/`). Strengthens the existing desaturation fix into a guarantee; biggest visual win per minute.
4. *(apply existing)* Extend baked worn foundations + procedural contact ellipses to the village zone's buildings/props (prop footprints into the geometry-guide step).
5. *(new rule for [[art/imagine-prompts]])* Author props in flat neutral light, no cast shadows — CanvasModulate + lights own time-of-day. Regenerate the worst offenders (well, fences, image-3 house).
6. *(new, gated on smoke test)* New props via `create_map_object` with the zone backdrop crop as `background_image`; fallback `generate-with-style-v2`.
7. *(new, tiny)* Scale chart pinned in [[art/imagine-prompts]] (player = 32 px ref; door ≈ 1.3× player; lamp, fence, well heights).
8. *(editor pass)* Collider on the image-2 wall; audit painted features vs StaticBody2D coverage; check the midday player-glow toggle.

## Filter test
Serves **horror beats** directly (the warm/cold zone thesis is a palette effect — it cannot land while props carry foreign palettes), **companion arcs** (Briar's pings/digs read as grounded only in a believable village edge), and **replay** (recontext moments need lived-in spaces to recontextualize). No story cost. Nothing here is a new mechanic; it all slots inside the existing content-complete-per-zone rule.

## Recommendation
Keep the entire stack. Run the PROPS-ONLY `edit_image` diagnostic on one screenshot to set the visual bar, smoke-test `create_map_object` against a backdrop crop, then execute fixes 1–8 as part of the village zone's conversion to the locked backdrop model — inside the existing zone-art/content-complete arc, before any new mechanics. Village *layout* stays a design task by necessity; the AI tools are now good enough that the manual job is composition and taste, not pixel production.
