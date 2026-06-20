---
name: Sprite tool for character variants — PixelLab (RD for static art)
date: 2026-06-10
tags: [decision, art-pipeline, ai-tools]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Character/Equipment Sprite Tool: PixelLab (Retro Diffusion for Static Art)

## Context
Grok Imagine cannot produce grid-aligned animation sheets (observed repeatedly 2026-06-10: drifting frames, oversized sprites looping in-game) — the upgrade trigger from [[design/ai-production-setup]] fired. The user asked which purpose-built tool best handles the *future* requirement: **changing weapons/armor/clothes while keeping the character consistent**. That requirement is already in the design: morality outfit states (innocent tunic → pragmatic cloak → marked Vessel, [[design/customization]]), 3 age stages, weapon progression, companion growth/corruption variants — all needing **frame-aligned** 4-direction animation sets so SpriteFrames can swap at runtime without pose pops.

## Decision
**PixelLab for characters, animation, and all variant work. Retro Diffusion (optional, $20 one-time Aseprite Lite) for static art. Grok Imagine stays for concept bibles/reference.**

Why PixelLab wins the equipment-consistency axis:
| Capability | PixelLab | Retro Diffusion |
|---|---|---|
| Saved character templates (reuse across jobs) | ✅ Characters page | ❌ prompt-only |
| Outfit change on existing sprite | ✅ Transfer Outfit Pro (across 2–15 anim frames) + true inpainting ("change shirt", "add sword") | ❌ regenerate from scratch |
| **Pose timing identical across variants** | ✅ reusable **skeleton rigs** drive re-skinned characters → frame-aligned variants | ❌ each generation independent → drift |
| 4/8-direction rotation from one sprite | ✅ | ❌ |
| Paper-doll layers (clothing-only overlays, transparent partials) | ✅ via inpaint/overlay prompts | ❌ manual cropping |
| Grid-true static pixel art / palette lock | good | ✅ best-in-class |
| Animation generation in Aseprite ext | ✅ (subscription) | ❌ static only |
| Cost | $9–30/mo tiers (pause-able) + sub-cent API | ~$0.01/img + $20 one-time ext |

The skeleton-rig point is decisive: runtime outfit swapping (our AgeMorph already swaps SpriteFrames) only works if frame N of `walk_down` is the same pose in every variant. PixelLab guarantees that by construction; RD makes it luck.

## Adoption plan
- **Not needed for the vertical slice** — current placeholders are settled. Subscribe to PixelLab (Artisan tier ~$25/mo) for 1–2 months **when character-variant work starts** (post-slice, around teen/adult stages or outfit states), batch-generate, pause subscription.
- Workflow then: define Rowan/Briar/creature as PixelLab character templates → skeleton rigs for walk/attack/idle → Transfer Outfit per morality state → 4-dir rotations → export sheets → existing `tools/pixelize.py` (alpha-aware) + `tools/gen_spriteframes.py` pipeline unchanged.
- **Drift-avoidance** *(2026-06-20 research, [[research/done/2026-06-20-pixel-art-pipeline-consistency]])*: feed a **clean orthographic turnaround** (front/side/back) as the style/reference image — not a painterly Grok concept; it's the single biggest lever against head/volume drift. Use the skeleton tool's **"fixed head → always"** option, and when rotating, regenerate at 45° increments **updating the reference each step** (errors accumulate — QA every step). An Aseprite hand-cleanup pass owns the last 10–15%.
- RD Aseprite Lite ($20 one-time) optional for tiles/icons if Grok tileset quality wall fires. *Caveat (2026-06-20): RD's Aseprite ext is static-only — animation needs the RD website/API/Replicate.*

## Alternatives
- **Retro Diffusion only**: rejected for characters — no skeleton/inpaint/outfit tooling; pose drift across variants breaks runtime swaps. Still best static-art quality; retained for that lane.
- **Ludo.ai**: animation-capable, 512px frames, MCP access — but $35/mo entry, no Aseprite plugin, less pixel-specialized. Revisit only if PixelLab disappoints.
- **Paper-doll system instead of variant sheets**: compatible with either tool but amplifies PixelLab's advantage (layer generation vs manual cropping). Deferred — 3 morality outfits × 3 ages is fine as full sheets; reconsider if equipment combinatorics grow.

## Consequences
- + Variant explosion (outfits × ages × directions × actions) becomes a template+transfer batch instead of prompt gambling.
- + PixelLab has API + a documented MCP/Claude Code workflow — variant batches automatable from the hub later (ideas inbox).
- − A subscription (pause-able) vs RD's one-time purchase; accepted for the months variant work actually happens.

## Lookback Questions
- Did skeleton reuse actually hold frame timing across outfit variants in practice?
- Did we end up wanting the paper-doll system anyway once weapons multiplied?

## Related
[[2026-06-10-recent-games-research-greenlight]] · [[design/ai-production-setup]] · [[design/customization]] · [[mechanics/progression]]
