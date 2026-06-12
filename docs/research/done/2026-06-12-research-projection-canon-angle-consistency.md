---
name: Research — Projection canon: angle consistency between Grok backdrops and generated props
date: 2026-06-12
source: claude.ai research session (web verification + training knowledge) + merged user-supplied cross-model note (Grok, 2026-06-12, unsourced — audited in §7)
prompt: "thorough research on how we can ensure that the grok backdrop image and the generated props always use the same angle so that they do not look out of place"
status: integrated
tags: [research, art, pipeline, projection]
related: "[[art/prop-coherence]] · [[art/imagine-prompts]] · [[decisions/2026-06-10-sprite-tool-pixellab]] · [[sessions/2026-06-11]] (backdrop art direction lock)"
markers: "[verified YYYY-MM-DD, source] = checked by Claude · [training knowledge] = stable knowledge, unsearched · [cross-model] = from the Grok note, not independently verified"
---

# Projection Canon — making backdrop and props share one camera

**Verdict:** two independent research passes (this one + the user-supplied
Grok note) converge on the same architecture — one named projection, locked
by reference-image inheritance, prompt grammar, and a QA gate, with zero
runtime cost. They differ in two places that matter: (1) this pass found the
concrete, verified root cause — **PixelLab tools ship with *different default
camera views per tool*** (`create_map_object` → *high top-down* ~35°,
`create_character` → *low top-down* ~20°), so any prop call that omitted
`view` was ~15° steeper than the characters; the Grok note attributes drift
generically to "the model picks its own top-down." (2) The Grok note's
fallback — extracting repainted props from `edit_image` output — **violates
prop-coherence rule 2** and stays rejected (§7). The fix is a fifth
prop-coherence rule (**Projection Canon**) plus making `view` structurally
impossible to omit. No reopened decisions.

---

## 1. Reframe: where the angle actually lives

- The locked pipeline (painter layout → geometry guide → Grok `edit_image`
  GROUND-ONLY repaint) means the backdrop is a near-plan-view ground plane.
  Grass, dirt, lanes: pitch-agnostic at 32 px. `[training knowledge]`
- Pitch signals come from anything with **height**: props (well, fences,
  lamps), buildings, characters, and the **baked worn foundations** painted
  into the backdrop (implied fronts). `[training knowledge]`
- "Backdrop and props at the same angle" decomposes into three jobs:
  1. keep the Grok ground **angle-neutral** (no foreshortening cues, no
     smuggled objects),
  2. pin **every sprite generator** to one canonical view,
  3. draw baked foundation fronts at the canon ratio in the geometry-guide
     step.
- **Naming the canon (shared vocabulary, adopted from the cross-model
  note):** the target look is the *Zelda perspective* — A Link to the Past /
  Terranigma / Secret of Mana: slightly elevated camera, tops **and** front
  faces visible, verticals stay vertical, no vanishing points. `[cross-model;
  consistent with the vault's Terranigma pass + farming-village reference]`
  Terminology correction: this is **not** "orthogonal dimetric" (an
  axonometric term) — it is a *cheated oblique / mixed projection* (floors in
  plan view, fronts in elevation view). PixelLab's matching control is the
  **oblique projection** flag, which their docs define as "the graphic style
  of the game Tibia." `[verified 2026-06-12,
  pixellab.ai/docs/options/projection]` Perfect geometry is not the goal;
  **consistent cheating** is. `[training knowledge]`
- Open check for the librarian: the cross-model note states ALttP-style is
  "the explicit reference in the art direction lock." Plausible, but the
  lock's exact wording wasn't in my snapshots — confirm against
  [[sessions/2026-06-11]] before treating the name as canonical.
  `[cross-model]`

## 2. Verified tool facts (the load-bearing ones)

### PixelLab camera vocabulary
- Documented camera views: **high top-down ≈ 35° look-down, low top-down
  ≈ 20°, side**. `[verified 2026-06-12, pixellab.ai/docs/options/guidance]`
- The same page states the view option **"weakly controls"** perspective —
  steering, not a guarantee. Hence the multi-lock design below.
  `[verified 2026-06-12, same page]`
- Projection flags are a separate option family: **isometric** and **oblique
  projection** (Tibia-style). `[verified 2026-06-12,
  pixellab.ai/docs/options/projection]`

### Per-tool `view` defaults (MCP docs, auto-generated 2026-06-11)
`[verified 2026-06-12, api.pixellab.ai/mcp/docs]`

| Tool | default `view` |
|---|---|
| `create_character` | **low top-down** |
| `create_8_direction_object` | **low top-down** |
| `create_map_object` | **high top-down** ⚠️ |
| `create_topdown_tileset` | **high top-down** ⚠️ |
| `create_1_direction_object` | **top-down** (a third value) ⚠️ |
| `create_tiles_pro` | `tile_view`: **low top-down**, plus numeric `tile_view_angle` + `tile_depth_ratio` |

→ **Smoking gun:** our prop path is `create_map_object`; our characters came
from the character tools. Left at defaults, props render ~35° and characters
~20°. This alone explains "props look out of place" independent of palette
and light (rules 1–2).

### Other relevant PixelLab capabilities
- `create_map_object` accepts `background_image` + `inpainting` alongside
  `view` — backdrop-crop workflow and explicit view **combine**.
  `[verified 2026-06-12, api.pixellab.ai/mcp/docs]` Both passes agree the
  crop is the designed-for inheritance path (style/palette/light/projection
  from the shown map portion — already `[verified 2026-06-12, pixellab.ai/mcp]`
  in [[art/prop-coherence]]). But the crop **cannot be the sole lock**: the
  view param is weak `[verified]` and reference-image params have a known
  500-failure mode server-side (the smoke-test gate in prop-coherence).
- **Image-to-image (depth)** tool with `depth_strength` guidance: copies the
  **depth/geometry of a reference image** into a new generation —
  ControlNet-style angle locking *inside the locked stack*. Feed an approved
  canon prop (or a 5-minute grey-box) as depth reference and the new prop
  inherits the exact pitch. `[verified 2026-06-12,
  pixellab.ai/docs/tools/image-to-image-depth + options/guidance]`
- `create_object_state` / `create_character_state` generate **variants of an
  existing asset** (seed support) — variants inherit the source's view.
  Recontext/VillageState prop variants should be *states of the canon
  object*, never fresh objects. `[verified 2026-06-12, api.pixellab.ai/mcp/docs]`
- Bitforge fallback caveat: MCP docs don't expose `generate-with-style-v2`
  params; confirm `view` / `oblique_projection` on that endpoint in the
  OpenAPI spec before relying on it
  (https://api.pixellab.ai/v2/openapi.json). `[endpoint existence verified
  2026-06-12; param list unconfirmed]`

### Grok Imagine (backdrop side)
- Current Grok Imagine image editing is **reference-based and prompt-level**:
  upload reference image(s) (up to 3), describe changes; the model preserves
  composition, and *explicit preservation instructions* ("keep all layout
  identical") reduce unwanted changes. Aspect-ratio control exists; **no
  structural camera/seed/angle parameter is surfaced** in current docs or API
  aggregators. `[verified 2026-06-12, help.scenario.com Grok Imagine guide;
  fal.ai/models/xai/grok-imagine-image/edit]` The cross-model note's claim
  that edit_image "preserves structure, lighting, and composition well"
  matches this. `[cross-model, corroborated]`
- Consequence: the `edit_image` GROUND-ONLY repaint is already the strongest
  available Grok-side angle lock — the painter layout *is* the composition
  Grok preserves. Residual risk is texture-level foreshortening and smuggled
  objects → prompt grammar + reject gate (§4). `[training knowledge + above]`

## 3. Rule 5 — Projection Canon (proposed addition to [[art/prop-coherence]])

> **5. Projection Canon ("Zelda perspective")**: one camera for the whole
> game — **low top-down (~20°), oblique projection** (fronts straight-on,
> verticals vertical, no vanishing points, no horizon). Every PixelLab call
> passes `view="low top-down"` **explicitly**; defaults are never trusted
> (they differ per tool). Grok ground repaints stay **angle-neutral**: plan
> view texture only, uniform texture density top-to-bottom, no objects, no
> foreshortening. Baked foundation fronts in the geometry guide follow the
> canon ratios below. Reference images pinned in [[art/imagine-prompts]]
> next to the scale chart.

**Why low top-down (and an audit before pinning it):**
- PixelLab labels low top-down the RPG view (high top-down = RTS).
  `[verified 2026-06-12, api.pixellab.ai/mcp/docs]`
- The cross-model note independently lands on "~20–30° elevation" for the
  ALttP look — straddling low top-down, well under 35°. Convergent.
  `[cross-model]`
- The **characters are the most expensive asset class to regenerate**
  (Rowan 14 animation rows, Briar 14, Twisted 9 — approved) and their tools
  default to low top-down. Props are ~$0.01–0.10 each to redo. The canon
  must match the characters; the asymmetry decides it. `[vault:
  state-and-roadmap]`
- **Audit first (30 min, do not skip):** overlay-measure 2–3 approved assets
  (a south-facing character sprite, the best prop, one building) against the
  ratio table. If the approved set actually sits nearer 35°, the canon flips
  — the rule is "match the characters," not "20° on principle."

**Canon ratio table (the measurable part)** `[training knowledge — basic
projection trig; ≈ values, eyeball-gate precision]`

| Cue | low top-down ~20° | high top-down ~35° |
|---|---|---|
| Ground circle (well rim, barrel top, bucket) | ellipse height ≈ **0.34×** width (~1:3) | ≈ 0.57× width (~4:7) |
| Box/cube: visible top depth vs front height | ≈ **1:3** | ≈ 2:3 |
| Verticals | stay vertical, never converge | same |
| Building roof | thin strip of roof, mostly facade | deep roof plane |

## 4. Enforcement — making "always" structural, not habitual

1. **Hard-code the canon in `tools/pixellab_api.py`**: module constant
   `CANON_VIEW = "low top-down"`; every wrapper sets it; an assert (or lint
   in `check-brain.sh` over `tools/`) fails any call site passing a
   different view without an explicit `# canon-override:` comment. This is
   the actual answer to "ensure … always": remove the human from the loop.
   *(code, small)*
2. **Belt and suspenders on props**: explicit `view` **and**
   `background_image` = real zone-backdrop crop **and**, where exposed,
   `oblique_projection`. Param is weak, crop is contextual (and can 500),
   flag is categorical — together they converge.
3. **Geometry lock for hero/problem props**: regenerate known offenders
   (well, fences, the image-3 house) via **image-to-image (depth)** with an
   approved canon asset or grey-box as depth reference, high
   `depth_strength`. Buildings first — largest area, strongest pitch signal.
4. **Prompt templates** (append to [[art/imagine-prompts]]; B and C adapted
   from the cross-model note):

   **A. Grok ground repaint (production backdrops — the only standing Grok
   pipeline):** *"top-down plan view of ground surface only; uniform texture
   scale across the whole image; no objects, no walls, no horizon, no
   shadows, no perspective; keep the layout exactly as given."* Leans on the
   verified preservation-instruction behavior; negative phrasing where the
   host UI supports it.

   **B. Grok full-scene (concept bibles / reference art only — never
   production backdrops):** *"angled top-down Zelda perspective (slightly
   elevated 3/4 view as in A Link to the Past / Terranigma), consistent
   foreshortening on every object, tops and front faces visible, verticals
   stay vertical, no linear perspective, no horizon, flat neutral light."*
   `[cross-model, adapted]`

   **C. `create_map_object` prop call (canonical):**
   `view="low top-down"` *(CANON_VIEW, code-enforced)* +
   `background_image=<zone backdrop crop>` + description: *"<prop>,
   transparent background, same angled top-down view, foreshortening and
   proportions as the background reference; tops and front face visible per
   the canon box; flat neutral light, no cast shadows, no baked time-of-day
   light; scale per the 32 px player chart."* `[cross-model, adapted]`
   ⚠️ Correction to the source note: its "inherit the 48-color palette"
   prompt line is steering at best — **rule 1's force-quantize post-pass
   remains the palette guarantee**, never the prompt.
5. **QA overlay gate** (extend the rule-4 check): a transparent Aseprite
   layer with the two canon ellipses, a canon box, and a vertical ruler;
   every new prop/building/repaint passes over it before import. Reject on:
   fat ellipses, converging verticals, deep roofs, ground texture that
   shrinks toward the top (depth cue).
6. **Variants via states**: all recontext/VillageState prop variants are
   `create_object_state` calls on the canon object — never fresh
   generations. Inherits view, seed-stable. `[verified 2026-06-12]`
7. **Foundations**: add canon front-height ratios to the geometry-guide step
   so baked foundations agree with the sprites standing on them.

## 5. What does NOT work (convergent across both passes)

- **Text-only prop prompts in isolation** → high angle drift (and now we
  know one mechanism: divergent per-tool defaults). `[both passes]`
- **Whole-scene generation + prop extraction** → loses the transparent-prop
  / y-sort workflow and collision-prop placement. `[cross-model, agreed]`
- **Style-reference-only** (without the actual backdrop crop or explicit
  view) → weaker projection lock. `[cross-model, consistent with the
  verified "weakly controls" caveat]`
- **External ControlNet/Blender depth pipeline** → doubly rejected: outside
  the locked stack `[cross-model]` **and unnecessary**, since PixelLab's
  depth i2i covers the geometry-lock case in-stack `[verified 2026-06-12]`.

## 6. Where it slots (systems + plan)

- **Amends, doesn't reopen**: backdrop art direction stays locked; this adds
  Rule 5 to [[art/prop-coherence]] and tightens steps 5–6 of its ordered fix
  plan (regeneration now under rules 1–3 **and 5**; the `create_map_object`
  smoke test must pass explicit `view`).
- **Stands on**: ZoneManager zone identity (per-zone backdrops), recontext
  groups (state-variant props, §4.6), VillageState routine props, y-sort +
  procedural contact shadows (rules already canon), the geometry-guide
  authoring step, `tools/pixellab_api.py` + job pool. DreadManager benefits
  indirectly: incoherent props are visual noise that flattens dread tells
  (screen distortion, companion fear behaviors) — coherence is what lets the
  horror signal read. `[cross-model framing, adopted]`
- **Runtime cost: zero.** Authoring-side only; nothing touches the Web/
  Android exports, no new addons, no stack change, no patent surface.

## 7. Cross-model merge audit (Grok note, user-supplied 2026-06-12)

**Adopted:** the "Zelda perspective" naming + reference-game anchor (§1);
the full-scene and prop prompt templates (§4 B/C, adapted); the
what-doesn't-work list (§5); the dread-legibility framing (§6); "reference
images pinned in imagine-prompts" (§3); the propose-only integration stance.

**Corrected:**
- "Orthogonal dimetric" → cheated oblique/mixed projection; PixelLab's
  `oblique_projection` flag is the matching control (§1).
- Palette-by-prompt → steering only; rule 1's quantize is the guarantee (§4C).
- Crop-as-sole-lock → necessary, not sufficient: view param is weak and the
  reference-image params have a known 500 failure mode (§2, §4.2).
- The note's `[verified 2026-06-12]` claims carry no sources → demoted to
  `[cross-model]` here unless independently verified above.

**Rejected:** the edit_image fallback step "then isolate just the new prop
on transparent background." Re-cropping repainted props bakes scene light
into the sprite — this is precisely the **rule 2 violation** prop-coherence
already documents, which is why the vault scopes edit_image to a
**benchmark-only** diagnostic. The vault stance stands. (Precedent noted:
the shadow canon was once garbled by a cross-model review — same audit
discipline applies here.)

**Missed by the note (this pass adds):** the per-tool default mismatch (the
verified root cause), the explicit `view` parameter and its code-level
enforcement, depth i2i as the in-stack geometry lock, object **states** for
angle-stable variants, and the measurable ratio gate.

## 8. Filter test

Serves **horror beats** directly: one coherent implied eye-height is what
lets the warm/cold zone thesis and quiet recontext changes register as
*wrongness in a real place* rather than kitbash noise — and what keeps
dread tells legible instead of drowned in visual noise. Serves **companion
arcs** (Briar's digs/pings read as grounded only when the well he digs
beside sits in the same world) and **replay** (recontext swaps must be
visually seamless or "same place, new truth" collapses). Adds no mechanic —
pipeline craft, same category as rules 1–4. Nothing here fails the filter;
the only flagged non-recommendation remains the external ControlNet/ComfyUI
escalation (§5).

## 9. Recommendation (ordered)

1. **Audit** 2–3 approved assets against the ratio table; pin the canon
   (expected: low top-down ~20°, matching the characters) and the
   "Zelda perspective" name (librarian confirms wording against the lock).
2. **Hard-code `CANON_VIEW`** in `tools/pixellab_api.py` + call-site assert;
   add Rule 5 to [[art/prop-coherence]]; add the three prompt templates +
   pinned reference images to [[art/imagine-prompts]].
3. **Regenerate the offender props/buildings** with explicit view +
   backdrop crop; use **depth i2i** for buildings and anything that resists.
4. **Adopt the QA overlay** as the import gate; extend the geometry guide
   with foundation front ratios.
5. Generate all future **variants as object states**, never fresh objects.
6. Keep edit_image strictly as the **benchmark diagnostic** (vault stance);
   do not adopt the cross-model note's prop-extraction fallback.

## Sources

- PixelLab MCP tool reference (defaults, params): https://api.pixellab.ai/mcp/docs `[verified 2026-06-12]`
- PixelLab guidance options (view angles, "weakly controls", depth strength): https://www.pixellab.ai/docs/options/guidance `[verified 2026-06-12]`
- PixelLab projection options (isometric / oblique): https://www.pixellab.ai/docs/options/projection `[verified 2026-06-12]`
- PixelLab image-to-image (depth): https://www.pixellab.ai/docs/tools/image-to-image-depth `[listed in docs nav, verified 2026-06-12; behavior per guidance page]`
- PixelLab v2 API index (endpoint existence, OpenAPI link): https://api.pixellab.ai/v2/llms.txt `[verified 2026-06-12]`
- Grok Imagine editing behavior (reference-based, preservation prompting, aspect ratios): https://help.scenario.com/articles/6027124401-grok-imagine-the-complete-guide-to-ai-generation-and-editing · https://fal.ai/models/xai/grok-imagine-image/edit `[verified 2026-06-12, third-party docs]`
- User-supplied cross-model research note (Grok, 2026-06-12): merged + audited in §7; no source links provided `[cross-model]`
- Oblique/mixed projection conventions for top-down RPGs: standard pixel-art practice `[training knowledge]`
