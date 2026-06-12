---
name: Gate validation + QA overlay artifacts (follow-up to projection canon)
date: 2026-06-12
source: claude.ai session — computational gate check on user-uploaded screenshots and sprite files; overlay PNGs generated in-session
prompt: "fence now looks natural, however i would prefer the well to also align to the same angle" + "does claude code know about the gate checks and qa overlay legend?"
status: inbox
related: "[[art/prop-coherence]] (rule 5) · [[art/imagine-prompts]] · research/done/2026-06-12-research-projection-canon-angle-consistency"
---

# Gate validation + overlay artifacts

## 1. New artifacts in repo `[verified 2026-06-12 — generated this session, user saved them]`

- `assets/reference/qa_overlay_128.png` — 128×128 transparent PNG, 1px crisp shapes:
  green canon ellipses **64×22** and **32×11** (= 0.34, low top-down ~20°), red reject
  ellipse **48×27** (= 0.57, high top-down ~35°), canon box **top 7 px / front 21 px**
  (1:3), double vertical ruler with 8px ticks, baseline.
- `assets/reference/qa_overlay_legend.png` — annotated how-to-read sheet.
- These **resolve the open user task "QA overlay layer in Aseprite"** — implemented as
  standalone PNGs instead; close that item in state-and-roadmap.

## 2. Empirical gate results `[measured 2026-06-12 from user uploads]`

- **fence_v2: PASS.** In-scene it reads natural (user verdict + screenshot). Sprite is
  48×42 vs old 64×24 — taller, more front face, which is why it sits right.
- **Edge check (both fence sprites): clean.** 0 semi-transparent pixels (no halo),
  edge-ring near-black share 0% (no hard outline). → The former pasted-on look was
  palette/shading/angle, **not** edges. **Rule-6 "edge canon" candidate: CLOSED — not
  needed.** No defringe step; `outline` param stays as is.
- **well_v2: FAIL.** Mouth ellipse measured **≈ 0.51 × width** (canon 0.34, reject ref
  0.57) — drawn at ~35° while the scene is ~20°. It *was* generated with
  `view="low top-down"` + backdrop crop, so this is empirical confirmation of the
  documented "view weakly controls" caveat, amplified by **iconic priors**: an image
  model's prior for "well" is the round hole seen from above. A fence has no such
  prior and passed on the first roll.

## 3. Rule-5 enforcement addendum (propose for [[art/prop-coherence]])

- **Iconic-prior props** (well, pond, cauldron, basin, anything defined by a round
  opening) need the angle carried in the **description content**, not just the param:
  side-visible wall, rim as a thin flat ellipse, interior not visible beyond a thin
  dark sliver. Escalate to image-to-image (depth) with a programmatic grey-box if
  2–3 rolls keep showing the mouth.
- **Gate instrument note:** pitched roofs legitimately show large slope area at low
  angles (classic Zelda houses are mostly roof) — roofs are NOT the pitch instrument.
  Horizontal circles (mouths, rims, barrel tops) are. Don't false-flag the cottage.

## 4. Pipeline correction `[user-reported 2026-06-12]`

User has **no Aseprite installed**. Where docs say "Aseprite cleanup/check", read
"any layer-capable editor (GIMP / Pixelorama / LibreSprite) **or scripted**". The
rule-5 gate goes editor-less via the gate-sheet script below; claude.ai can also gate
uploaded PNGs/screenshots directly (done this session for well + fence).

## 5. Work order for Claude Code (execute now)

1. **Regenerate the well at canon** — param alone isn't carrying it for this prop.
   `create_map_object`, `view="low top-down"`, `background_image` = crop of its
   village spot, description: *"old stone village well seen from a low angle in SNES
   Zelda-style top-down: cylindrical stone wall visible from the side, rim is a thin
   flat ellipse, interior opening not visible except a thin dark sliver at the back,
   two vertical wooden posts, small pitched roof showing mostly its front slope,
   hanging bucket, flat neutral light, no cast shadows, transparent background."*
   2–3 rolls; if every roll still shows an open round mouth, escalate to
   image-to-image (depth) with a programmatically drawn grey-box depth reference
   (cylinder side + thin top ellipse + posts + roof slab at canon proportions),
   high `depth_strength`.
2. **Add `tools/gate_sheet.py`**: composite `assets/reference/qa_overlay_128.png`
   (centered, ~70% opacity) onto every PNG in `candidates/` at 4× nearest-neighbor,
   write one `gate_sheet.png` contact sheet for eyeball review in any image viewer.
3. **Batch-regenerate the remaining village props** under the proven recipe
   (explicit view + placement-spot crop + palette lock) and run them through the
   gate sheet **before** the user places anything.

## 6. Status updates for state-and-roadmap

- User editor pass: fence_v2 + well_v2 swapped in (offsets + colliders done for
  these two); well_v2 to be replaced after the §5.1 regen.
- Item-7 audit (stone-wall StaticBody2D, collider-coverage walk, midday glow):
  **still open** unless the user reports otherwise.
- "Pin reference crops in [[art/imagine-prompts]]": unchanged, still open.

## Recommendation

Librarian integrates §1–4 (artifact spec into prop-coherence, addendum + instrument
note into rule 5, close rule-6 candidate, Aseprite wording fix, close the overlay
task); §5 is a Claude Code work order, not vault prose; §6 updates the session log.
Nothing here reopens locked decisions.
