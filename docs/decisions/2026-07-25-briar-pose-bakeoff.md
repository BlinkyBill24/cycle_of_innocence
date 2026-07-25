---
name: Briar stand-in pose bake-off (Imagine vs PixelLab vs Sorceress)
date: 2026-07-25
tags: [decision, art, pipeline, briar, bakeoff]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Briar stand-in pose bake-off (Imagine vs PixelLab vs Sorceress)

## Context

STATE “Next” needed real art for Briar’s **cower / dusk_press / head_bump / lie_down**
(currently idle stand-ins in `briar_v2_frames`). Phase 2 of the one-person-studio plan
([[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]) required a
scored bake-off before adding [Sorceress.games](https://sorceress.games/) to the stack.

**Subject:** four single-frame stand-in poses (south-facing), same Briar V2 Malinois pup
identity (fawn/tan, black mask, upright ears, collar bell).

**Arms**

| Arm | Method |
|---|---|
| **A — Grok Imagine** | `image_edit` from V2 style ref + idle frame → magenta bg → crop/fit 48px cell |
| **B — PixelLab** | `generate-image-bitforge` 64×64, `view=low top-down`, style+init anchors (after resize) |
| **C — Sorceress** | Auto-Sprite / True Pixel / Pixel Snap — **not executed** (browser account / credits not available in agent session) |

Artifacts: `assets/reference/bakeoff_2026-07-25/` (anchors, arm_a, arm_b, scored compare sheet).

## Decision

1. **For emotional stand-in poses right now: ship Arm A (Grok Imagine) as interim drafts** wired into `briar_v2` anim folders and rebuilt `briar_v2_frames` / `briar_v2_pup.png`. Readable cower / press / head-bump / lie-down beat “reuse idle.”
2. **PixelLab remains canonical for multi-direction locomotion / skeleton-grid work** (unchanged from [[2026-06-10-sprite-tool-pixellab]]). Bitforge in this bake-off **held identity/style** but **failed pose change** (all four outputs ≈ standing idle).
3. **Do not add Sorceress to the production stack yet.** Keep as optional human trial (recipe in bake-off folder). Revisit only if a human run beats Arm A pose clarity *and* Arm B style lock on the same anchors.
4. **Human pixel polish still required** before calling these ship-final (projection toward side/3/4, softer AA edges, scale match to walk cycle).

## Scorecard (0–5)

| Criterion | A Imagine | B PixelLab | C Sorceress |
|---|---|---|---|
| On-model to Briar V2 | 4 | 4 | — not run |
| 32/48px clarity | 3 (soft edges; needs pixelize/hand) | 4 (true small grid) | — |
| Pose distinctness | **5** | **1** (idle lock) | — |
| 4-dir readiness | 2 (single south only) | 2 (single; no pose) | — |
| Palette / style vs V2 sheet | 3 (richer/softer) | **4** | — |
| Time-to-import | 4 (~minutes agent) | 3 (API sizing pitfalls first) | — |
| Commercial clarity | 3 (Grok; human edit trail) | 4 (PixelLab known) | ? |
| Human edit burden | 3 | 2 if pose worked | ? |
| **Total (sum)** | **24** | **20** | n/a |

**Winner for this job (pose stand-ins):** **Arm A**.  
**Winner for style/grid discipline:** Arm B (but unusable until pose control works).

## Alternatives considered

- Leave idle stand-ins — rejected; quirks/fear unreadable in F5.
- Wait for full Sorceress trial before any ship — rejected; Arm A already unblocks readable poses.
- Replace PixelLab with Imagine for all character anims — rejected; multi-dir grids still need PixelLab.
- WizardGenie / engine switch — rejected (Godot locked).

## Implementation

- Branch: `feature/briar-pose-bakeoff`
- Anchors + arms under `assets/reference/bakeoff_2026-07-25/`
- Wired: `assets/companions/briar/puppy_v2/anim/{cower,dusk_press,head_bump,lie_down}/south/frame_00.png`
- `tools/build_briar_v2_spriteframes.py` MAP points those anim names at dedicated folders
- Rebuilt `assets/sprites/companions/briar_v2_pup.png` + `assets/resources/companions/briar_v2_frames.tres`
- Arm C human recipe: `assets/reference/bakeoff_2026-07-25/arm_c_sorceress/README.md`
- Prompt log: [[art/imagine-prompts]] (2026-07-25 section)

## Lookback questions

- Do the Imagine poses read at game scale in F5 (fear vs press vs lie)?
- Does PixelLab `animate-with-text` or skeleton action templates succeed for these four where bitforge failed?
- Human Sorceress trial: better pose+pixel than Arm A?

## Related

[[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]] ·
[[design/ai-production-setup]] · [[2026-06-10-sprite-tool-pixellab]] ·
[[art/imagine-prompts]] · [[design/agentic-playtest-smoke]]
