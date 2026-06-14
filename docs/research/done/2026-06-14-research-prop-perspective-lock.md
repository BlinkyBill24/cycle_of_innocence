---
name: "2026-06-14-research-prop-perspective-lock"
date: 2026-06-14
source: "web (pixellab.ai/docs) + existing project canon (mechanics-compendium / prop-coherence)"
prompt: "Why do PixelLab props (e.g. a dining table) come out in the wrong perspective vs the ALttP house-interior reference, while a bed reads roughly correct, and what is needed to generate furniture in the correct (canon low top-down) perspective?"
status: integrated
tags: [research, art, pixellab, projection, props]
---

# Prop perspective lock — PixelLab furniture in canon low-top-down

## Question / context
Furniture generated through PixelLab's standalone *Create Object* flow (description-only prompts such as "large rectangular wooden dining table … top and front visible, straight verticals") renders in the wrong perspective against the ALttP house-interior reference. A bed generated the same way reads roughly correct; the table does not. What is actually required to pin the canon perspective?

## Findings

### Root cause: the `view` parameter is weak, so the model's prior wins
- PixelLab's own option docs state the perspective control **only weakly influences** the drawn perspective, and define the angle presets as **high top-down ≈ 35°** and **low top-down ≈ 20°**. `[verified 2026-06-14, pixellab.ai/docs/options/guidance]`
- A **description-only** generation therefore lets the model's built-in prior dominate geometry. For "dining table" that prior is a 3/4 product-catalog view, which fights a flat top-down floor plane. `[training knowledge]`
- This is the same failure mode already recorded for legacy description-only ("pixflux") props in this project — the slide read isometric, the roundabout ellipse was too round — and for "iconic-prior" round-mouth props (well measured 0.51 ratio param-only → FAIL). `[existing canon: mechanics-compendium, prop-coherence rule 6]`

### Why the bed survived and the table didn't
- A bed is low and top-surface-dominant: its catalog silhouette and the canon ~20° low-top-down silhouette nearly coincide, so there is little vertical face for the prior to distort. `[training knowledge]`
- A table is vertical-dominant (legs + tabletop edge): strong pitch signal + a strong foreshortened-top prior → it diverges from the flat floor. **Every vertical-heavy prop (table, chairs, shelves, wardrobe, cupboard) will fail identically.** This is the geometry-resistant class already flagged for buildings and stairs. `[training knowledge + existing canon]`

### What fixes it: a reference image, not better prose
Prompt text cannot pin geometry; perspective jargon ("top and front visible, straight verticals") and style tags ("classic Zelda house interior") do not translate into projection for the model. The reliable levers, in order of leverage:
1. **Use the reference path, not the bare prompt box.** The production recipe all approved village props used: `create_map_object` with `view="low top-down"` set explicitly **+ a crop of the actual interior floor as `background_image`** → style, palette, light, and projection are inherited from the crop; output stays a transparent sprite. `[existing canon, verified 2026-06-12 in vault]`
2. **For vertical-heavy props, escalate straight to image-to-image (depth).** PixelLab exposes a depth-reference strength — the docs describe a control for **how much the model copies the depth of the reference image** — and the *Image to image (depth)* tool is live in the current tool list. `[verified 2026-06-14, pixellab.ai/docs/options/guidance + tools list]` Feed a 5-minute grey-box built at canon angle (or an existing on-canon sprite) as the depth reference with high `depth_strength` → ControlNet-style angle lock that overrides the prior. For furniture, do **not** spend rolls on view+crop alone; it will not converge. `[existing canon: geometry-lock decision, verified 2026-06-12]`
3. **Always set `view="low top-down"` explicitly.** The map-object / tileset tools default to **high top-down ≈ 35°** — off-canon before the prior even applies. Weak, but still pin it. `[verified 2026-06-14, docs + existing canon rule 5]`
4. **Describe the silhouette, not the camera.** Encode the canon **top:front ≈ 1:3** ratio as geometry, e.g. "thin tabletop as a shallow flat slab, all four legs fully visible below the front edge, only a sliver of the top surface showing." `[training knowledge; ratio from existing canon ratio table]`
5. **Then palette-lock + gate.** `tools/palette_lock.py` + the QA overlay / `gate_sheet.py`: top:front ≈ 1:3, verticals never converge, ground ellipses ≈ 0.34× width. `[existing canon]`

### Caveat — the ALttP reference is a *higher* oblique than canon
ALttP interior furniture is drawn closer to near-front-elevation (very little tabletop visible) — a higher oblique than the project's ~20° low-top-down canon. Depth-referencing straight off the ALttP screenshot would pull props toward ALttP's angle, not the project canon. **Use ALttP as mood/aesthetic reference only; build the depth grey-box / anchor to the canon ratio.** The already-approved bed is a usable on-canon anchor. `[training knowledge — flag, not verified against pixel measurement]`

## Maps to existing systems
- **Projection Canon (rule 5)** — confirms "view explicit, defaults never trusted"; adds furniture to the geometry-resistant class alongside buildings/stairs/iconic-prior props.
- **Prop generation workflow** — the multi-lock (view + backdrop crop; depth-i2i escalation; `create_object_state` for variants) applies unchanged; this is a *which-tier* clarification, not a new mechanic.
- **Palette hard-lock (rule 1) + gate** — unchanged final steps.
- **No code/mechanic changes implied.**

## Filter (story / companion / horror / replay)
Indirect but real, consistent with the prop-coherence thesis: correct, consistent perspective is a prerequisite for the warm/cold palette horror beat to land (props must read as *of the world*), for companion-arc village space to read lived-in rather than kitbashed, and for recontext replay moments to have a coherent space to recontextualize. No filter failures; nothing to flag for removal.

## Recommendation
For all vertical-heavy interior furniture (table, chairs, shelves, wardrobe, cupboard): go directly to **image-to-image (depth)** with a canon-angle grey-box (or the on-canon bed) as the depth reference at high `depth_strength`, `view="low top-down"` explicit, then palette-lock + gate. Reserve the cheaper **view + backdrop-crop** path for flat / top-dominant props (rugs, beds, low chests), where it already converges. Treat ALttP as mood reference only; anchor geometry to the canon 1:3 top:front ratio.

## Sources
- PixelLab — Options / Guidance (view "weakly controls"; high ≈35° / low ≈20°; reference, style, and depth strength controls): https://www.pixellab.ai/docs/options/guidance `[verified 2026-06-14]`
- PixelLab — tool list incl. *Image to image (depth)*: https://www.pixellab.ai/docs/tools/animation-to-animation (sidebar) `[verified 2026-06-14]`
- PixelLab — image-to-image (depth) tool page (referenced in vault canon): https://www.pixellab.ai/docs/tools/image-to-image-depth `[verified 2026-06-12 in prior vault note; not re-fetched 2026-06-14]`
- Existing project canon: `mechanics-compendium` (Projection Canon rule 5, prop workflow, ratio table, gate), `art/prop-coherence` — `[internal, not re-verified]`
