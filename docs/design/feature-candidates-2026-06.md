---
name: Feature Candidates — Recent Games Research (Round 2)
date: 2026-06-10
tags: [design, research, features]
status: active
related_decisions: [[decisions/2026-06-10-recent-games-research-greenlight]]
---

# Feature Candidates from Recent Games (2022–2026) — Research Round 2

Round 1 ([[decisions/2026-06-10-new-features-and-ai-setup]]) covered genre classics. This round mines **recent releases** for unique mechanics, filtered against existing design and the locked stack (Godot 4.4 GDScript, Dialogue Manager, LimboAI, 32×32, solo dev, Linux/Android/Web).

## Per-game findings (condensed — unique mechanics only)

| Game (year) | Unique mechanic(s) | Fit |
|---|---|---|
| **Look Outside** (2025) | Transformation-as-gameplay: observing the phenomenon mutates the body; mutations spread by proximity; enemy phases evolve mid-fight | Tonally aligned; transformation tracking = state machine + sprite tiers (our corruption already does this) |
| **Pacific Drive** (2024) | **Quirk system**: companion (car) develops persistent, diagnosable behavioral quirks; trust erosion → refusal | ★ Greenlit → [[mechanics/companion-quirks]] |
| **Dredge** (2023) | Sanity spiral: hallucinations become unreliable *guides*, not just scares; risk-asymmetric day/night | Day/night already greenlit; false-guide hallucinations → refinement in [[mechanics/vision-and-darkness]] |
| **Mouthwashing** (2024) | Unreliable narrator dialogue (what you pick ≠ what is said); world spatially shrinks over time | ★ Greenlit (dialogue) → [[mechanics/interface-horror]]; map-shrink already in [[mechanics/hollowing-clock]] |
| **Heartworm** (2024) | Control degradation as possession horror (input stutter/delay/inversion) | ★ Greenlit → [[mechanics/interface-horror]] |
| **Sorry We're Closed** (2024) | Ambient/overheard narrative — conspiracy leaks via background dialogue and mundane wrongness | ★ Greenlit → [[mechanics/village-life]] |
| **Shadows of Doubt** (2023) | NPC daily routines (work/lunch/sleep schedules) you observe and exploit | ★ Greenlit (scaled to ~12 NPCs) → [[mechanics/village-life]] |
| **Void Stranger** (2023) | Knowledge-gated recontextualization: old rooms function differently once you know things | ★ Greenlit → [[mechanics/zone-recontextualization]] |
| **Animal Well** (2024) | Tool layering: every item has 3-5 cross-context uses; secrets in plain sight | Design rule adopted (ideas inbox): every companion ability needs 2-3 uses before it ships |
| **Undertale Yellow** (2023) | Per-enemy unique mercy interactions; repeating generic actions wastes turns | Refinement → [[mechanics/encounters-mercy]] |
| **In Stars and Time** (2023) | Loop-aware NPC memory: fractional remembered details across loops | Refinement → NG+ echoes in [[mechanics/progression]] |
| **Cult of the Lamb** (2022+) | Sacrifice with mechanical teeth (power vs loyalty); dual action/management loop | Sacrifice tension already core story; management loop rejected (scope) |
| **Crow Country** (2024) | Fully beatable with zero combat; multi-solution puzzles | Stretch accessibility goal (ideas inbox); mercy path partially covers |
| **Slay the Princess** (2023) | Choices vs the game's memory of what "really" happened | Flavor for NG+; no new system |
| **The Coffin of Andy and Leyley** (2023) | Small dialogue choices cascade into long-term relational decay | Validates our existing dialogue→bond/corruption mapping; no new system |
| **Hades II** (2024-25) | Familiar recruitment/upgrade via tokens | Rejected — conflicts with 3 fixed story companions |
| **Dave the Diver** (2023) | Tiered staff recruitment economy | Rejected — recruitment economy off-theme |
| **Lorelei and the Laser Eyes** (2024) | Real-world-knowledge puzzle language; learn the game's symbols | Partial: ritual-symbol literacy as puzzle flavor (ideas inbox) |
| **Leap Year** (2024) | Progression = knowledge only, zero new abilities | Philosophy already ours (no XP); affirmation |
| **Roadwarden** (2022) | Time+reputation economy; appearance affects prices | Per-NPC suspicion absorbed into [[mechanics/village-life]] + hollowing alarm points |
| **Moonring** (2023) | Free-form dread systems in top-down retro RPG; regenerating dungeons | Procedural dungeons rejected (handcrafted zones locked) |
| **Stifled / Phasmophobia** | Microphone-as-input horror | Rejected — Web/Android API pitfalls, accessibility |
| Godot practice (2024+) | 3-stem adaptive audio (ambient/tense/danger) via AdaptiSound (FOSS) | ★ Greenlit → [[mechanics/adaptive-audio]] |

## Tiers

- **Tier A — greenlit, slice-adjacent (cheap, high horror-per-line-of-code)**: [[mechanics/companion-quirks]] · [[mechanics/interface-horror]] · [[mechanics/adaptive-audio]] · gossip half of [[mechanics/village-life]]
- **Tier B — greenlit, post-slice (systemic)**: NPC schedules ([[mechanics/village-life]]) · [[mechanics/zone-recontextualization]] · ability-layering design rule
- **Tier C — refinements appended to round-1 docs**: unique soothe interactions (mercy) · hallucinated false pings (vision) · loop-memory dialogue (progression/NG+)
- **Rejected**: microphone input, procedural dungeons, settlement/follower management, recruitment/economy tiers, card mechanics

## Build-order note
Nothing here preempts the vertical slice. Slice ships first (child Rowan + Briar + one zone); Tier A features are designed to bolt onto systems the slice already exercises (companions dict, dialogue, dread, audio buses).

## Related
[[design/game-features]] · [[decisions/2026-06-10-recent-games-research-greenlight]] · [[ideas]]
