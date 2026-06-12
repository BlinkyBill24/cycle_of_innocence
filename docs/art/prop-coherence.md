---
name: Prop Coherence — rules & fix plan
date: 2026-06-12
tags: [art, pipeline, rules]
status: active
related_decisions: "[[sessions/2026-06-11]] (backdrop art direction lock)"
---

# Prop Coherence — Rules & Fix Plan

Source: art-tooling research + cross-model (Grok) review
([[research/done/2026-06-12-research-art-tooling-prop-coherence]]), corrected
by local verification 2026-06-12.

**Verdict (convergent across two models + audit): the stack is right; the
screenshot failures are a compositing/workflow gap, not a tooling gap.**
PixelLab characters, Grok GROUND-ONLY backdrop repaints, and the hand-rolled
adaptive audio are all reaffirmed — keep the locked art lane.

**Mid-2026 reality check** `[verified 2026-06-12]`: AI map tooling is
asset/tileset-level everywhere (PixelLab map tools are guided inpainting;
Ludo.ai is tilesets; nothing layout-level exists). Nothing one-shots a village
that "makes sense." Layout stays design work here **by necessity** — it is
load-bearing: VillageState routine markers, eavesdrop zone placement, Warden
patrol readability, recontext groups. Zones must read as *lived-in conspiracy
spaces, not modular kitbash* — that is the replay-value stake.

## Rules (apply to every prop, every zone)

1. **Palette hard-lock**: extract each zone backdrop's 48-color palette;
   force-quantize every prop to it — shipped implementation:
   `tools/palette_lock.py` (nearest-RGB, alpha preserved, `--dry-run`).
   Upgrades the Terranigma-pass desaturation fix into a guarantee. Biggest
   visual win per minute. **Authored saturation exemptions**: props whose
   wrongness IS the design stay unlocked — currently only `toy_duck.png`
   ("toys stay saturated while the world drains"). Applied to village props
   2026-06-12, playground props (minus duck) same day.
2. **Flat-neutral-light authoring**: props carry NO baked time-of-day light
   and NO cast shadows — `CanvasModulate` + lights own time-of-day. (A prop
   repainted to match one scene's light is wrong in every other scene.)
3. **Scale chart** (pin in [[art/imagine-prompts]]): player = 32 px reference;
   door ≈ 1.3× player; lamp/fence/well heights pinned alongside.
4. **Shadow canon (restated — a cross-model review garbled it)**: procedural
   contact-shadow ellipses for small props; baked worn foundations for
   buildings; **no shadow ellipses on ≥96 px sprites** (they caused floating).
5. **Projection Canon ("Zelda perspective")** *(research 2026-06-12,
   [[research/done/2026-06-12-research-projection-canon-angle-consistency]])*:
   one camera for the whole game — **low top-down (~20°), cheated
   oblique/mixed projection** (floors in plan view, fronts in elevation; tops
   AND front faces visible, verticals stay vertical, no vanishing points, no
   horizon). Perfect geometry is not the goal; **consistent cheating** is.
   - Every PixelLab call passes `view="low top-down"` **explicitly — defaults
     are never trusted**: they differ per tool (`create_map_object` /
     `create_topdown_tileset` default *high top-down* ≈35°; character tools
     default *low top-down* ≈20°) `[verified 2026-06-12, MCP docs + local
     schema]`. `check-brain.sh` lints `tools/*.py` for off-canon views
     (`# canon-override:` comment to exempt deliberately).
   - **Canon provenance** (stronger than overlay measurement): every
     production script already pinned `low top-down` at its call site
     (pixellab_props/village_props/npcs/v2.py) — all approved assets ARE the
     canon. The only drift ever shipped was the 2026-06-12 candidates,
     generated at high top-down through the then-viewless item-6 recipe
     (regenerated same day).
   - Grok ground repaints stay **angle-neutral**: plan-view texture only,
     uniform texture density top-to-bottom, no objects, no foreshortening, no
     shadows (templates in [[art/imagine-prompts]]).
   - Baked foundation fronts in the geometry-guide step follow the canon
     ratios below.
   - **Canon ratio table** (eyeball QA gate; ≈ values):
     ground circle (well rim, barrel top) ellipse height ≈ **0.34× width**
     (~1:3; high top-down ≈ 0.57× — reject); box visible top depth : front
     height ≈ **1:3** (high ≈ 2:3); verticals never converge; buildings show
     a **thin roof strip, mostly facade** (deep roof plane = wrong camera).
   - **QA overlay import gate (instruments shipped 2026-06-12)**:
     `assets/reference/qa_overlay_128.png` — green canon ellipses **64×22**
     and **32×11** (= 0.34, ~20°), red reject ellipse **48×27** (= 0.57,
     ~35°), canon box **top 7 px / front 21 px** (1:3), double vertical ruler
     with 8 px ticks — plus `qa_overlay_legend.png` (how to read it) and
     `tools/gate_sheet.py` (editor-less: composites the overlay onto
     `candidates/*.png` at 4× NN into one contact sheet). Every new
     prop/building/repaint passes before import. Reject on fat ellipses,
     converging verticals, or ground texture that shrinks toward the top.
   - **Gate instrument note**: pitched roofs legitimately show large slope
     area at low angles (classic Zelda houses are mostly roof) — **roofs are
     NOT the pitch instrument; horizontal circles are** (mouths, rims,
     barrel tops). Don't false-flag the cottage or the stall awning.
   - **Iconic-prior props** (well, pond, cauldron, basin — anything defined
     by a round opening): the model's prior is the open mouth seen from
     above, and `view` alone won't override it ("weakly controls",
     empirically: param-only well measured 0.51 → FAIL). Carry the angle in
     the **description content** — side-visible wall, rim as a thin flat
     ellipse, interior not visible beyond a thin dark sliver — (validated:
     PASS on roll 1); escalate to image-to-image (depth) with a programmatic
     grey-box only after 2–3 failed rolls.
   - **"Edge canon" rule-6 candidate: CLOSED — not needed** (empirical edge
     check 2026-06-12: 0 semi-transparent pixels, no near-black outline
     ring on either fence; the pasted-on look was palette/shading/angle).
     No defringe step; the `outline` param stays as is.
   - **Legacy audit (2026-06-12, ratio glance)**: terrace/cliff tileset PASS,
     chapel roof PASS — the pre-explicit-view assets already sit on the
     canon; no depth-i2i rework needed. Pinned references:
     `assets/reference/canon_view_character.png` + `canon_view_prop.png`
     ([[art/imagine-prompts]]). Lint also covers the `tile_view` key
     spelling.

## Prop generation workflow

- **New props**: PixelLab `create_map_object` with `view="low top-down"`
  (rule 5 — ALWAYS explicit) + a crop of the actual zone backdrop as
  `background_image` (style/palette/light inherited; output stays a
  transparent sprite for y-sort/collision) `[verified 2026-06-12,
  pixellab.ai/mcp]` — the multi-lock: the view param is weak ("weakly
  controls", per PixelLab docs), the crop is contextual (and reference params
  have a known 500 failure mode), so view + crop together converge. Fallback
  is `generate-with-style-v2`/bitforge with the same crop (confirm its
  `view`/`oblique_projection` params against the OpenAPI spec before relying
  on it).
- **Variants** (recontext / VillageState states of an existing prop): always
  `create_object_state` on the canon object — inherits view, seed-stable —
  **never a fresh generation**. `[verified 2026-06-12, MCP docs]`
- **Geometry lock for resistant props/buildings**: PixelLab **image-to-image
  (depth)** with an approved canon asset (or 5-minute grey-box) as depth
  reference, high `depth_strength` — ControlNet-style angle lock inside the
  locked stack. Buildings first: largest area, strongest pitch signal.
  `[verified 2026-06-12, pixellab.ai/docs/tools/image-to-image-depth]`
- **PROPS-ONLY `edit_image` diagnostic**: one repaint pass on a real composited
  screenshot ("repaint the lantern/bench/well to match the ground lighting and
  palette") to set the visual bar before regenerating anything. **Benchmark
  only, never the standing pipeline** — re-cropping repainted props bakes
  scene light into the sprite (violates rule 2).

## Ordered fix plan (cheap → structural; verified state 2026-06-12)

1. ~~Remove courtyard decal instances~~ — **already clean in repo** (no
   decal/courtyard/set-piece nodes in any scene; the reviewed screenshots were
   stale vintages).
2. ~~Clamp Camera2D limits to backdrop rects~~ — **DONE 2026-06-12**
   (branch `fix/zone-coherence-camera-palette`): `ZoneRoot` clamps the player
   camera to the `GroundBackdrop` rect + 16px bleed on zone enter, and resets
   limits in zones without a backdrop so clamps never leak across transitions.
3. ~~Palette hard-lock pass over existing village props~~ — **DONE
   2026-06-12** (same branch): new `tools/palette_lock.py` (PIL,
   nearest-RGB remap, alpha preserved, `--dry-run`); all 10 village props
   were 100% off-palette and are now locked to the backdrop's 48 colors.
   Expected casualty: cool accents (chapel roof) went warm-olive — the
   palette has no cool colors by design; polish via item 5 regen if needed.
4. ~~Extend foundations + contact ellipses to the village zone~~ — **VERIFIED
   ALREADY COVERED 2026-06-12**: `PropShadows.apply($World)` runs in BOTH zone
   scripts (village_green.gd:50), village props follow the StaticBody2D+
   Sprite2D pattern it targets, and village buildings sit on baked worn
   foundations since the backdrop lock. The research screenshots predated
   this (stale vintages).
5. ~~Regenerate worst offenders~~ — **DONE 2026-06-12** in three rounds:
   staged at canon view → user placed well_v2 + fence_v2 in the editor
   (offsets + colliders) → gate caught well_v2 at 0.51 (iconic prior) →
   prior-busting regen PASS roll 1, replaced in place (44×51 vs 54×60 — well
   collider needs a nudge). Remaining props (bench, lantern_post,
   harmony_board, market_stall) batch-regenerated at their placement-spot
   crops, palette-locked, **all six gated PASS** — staged in `candidates/`
   awaiting placement.
   Buildings deliberately NOT regenerated: palette lock + baked foundations
   already ground them, and a regen would fight the foundations painted into
   the backdrop.
6. ~~`create_map_object` smoke test~~ — **PASSED 2026-06-12**: no server-side
   500 (unlike create-tileset's reference params); style/projection inherited
   from the backdrop crop; palette only partially inherited → run
   `tools/palette_lock.py` on every result. **Production recipe**: crop the
   zone backdrop where the prop will stand → background_image (the MCP path
   mode hands back a curl command — key comes from `~/.config/pixellab/api_key`,
   never inline) → **`view="low top-down"` explicit (rule 5)** → object size ≈
   crop size × oval fraction (64px crop + fraction 0.72 ≈ 45–60px prop; 128px
   crop ≈ 75px+ prop — pick crop size for target scale) → trim transparent
   border → palette-lock → ratio-table/QA-overlay check → stage in
   `assets/sprites/village/candidates/` for editor placement (placement/scale
   is the user's editor pass).
7. **Editor pass (user) — THE ONLY OPEN ITEM**: missing StaticBody2D on the
   painted stone wall; audit painted features vs collider coverage; check
   the midday player-glow toggle; nudge the well collider (item-5 in-place
   regen). ~~Place the four new gated candidates~~ — texture swaps done
   mechanically 2026-06-12 (base-anchored offsets; bench/stall same-height,
   board −10 px, lantern +2 px ×4 instances); **verify colliders in the
   editor** (board and stall changed footprint width).

8. **Rework round 2 (2026-06-12, user feedback "cottages/houses + playground
   props/trees look off")**: playground props palette-locked (duck exempt,
   rule 1); buildings REGENERATED after all — the foundation-fight concern
   was answered by inpainting at the placement-spot crop (the baked
   foundation is IN the crop, so the model draws the building on it):
   `candidates/cottage_a_v2/b_v2/dark_v2/chapel_v2` (village) +
   `props/candidates/dead_tree_a_v2/b_v2` (playground), all canon view,
   palette-locked, gated PASS. **Note: new buildings are TALLER than the old
   slabs** (e.g. cottage_a 138×146 vs 128×112) — placement + collider fit is
   an editor judgment, not a mechanical swap.
## Filter test

Serves **horror beats** directly (the warm/cold zone thesis is a palette
effect — it cannot land while props carry foreign palettes), **companion
arcs** (Briar's pings/digs read as grounded only in a believable village
edge), and **replay** (recontext moments need lived-in spaces to
recontextualize). No new mechanics — everything slots inside the
content-complete-per-zone rule.

## Related

[[art/imagine-prompts]] · [[plan/slice-implementation-roadmap]] ·
[[research/done/2026-06-12-research-art-tooling-prop-coherence]] ·
[[sessions/2026-06-11]]
