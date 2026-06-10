---
name: Adaptive Audio (Stem Layers)
date: 2026-06-10
tags: [feature, mechanics, audio, horror]
status: planned
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Adaptive Audio — Three Stems and a Heartbeat

## What it does
Music and ambience are authored as **stacked stems** (ambient / tense / danger + a companion vocal layer) whose volumes crossfade continuously from game state — dread level, time of day, hollowing stage, companion fear. The score *is* the dread meter the player actually perceives.

## Why it fits (prior art check, R3b)
- [[design/game-features]] §12 already promises "adaptive layers… dynamic mixing based on dread" — this is the concrete design + implementation path.
- Slots into the FOSS pipeline: stems generated with ACE-Step ([[design/ai-production-setup]]), mixed in Audacity, played via Godot AudioBus.

## v2 implementation note (2026-06-10, slice-gate fix)
Layered playback clashed in the gate playtest — the ACE-Step tracks are independent compositions, not aligned stems. **v2 crossfades exclusively**: one intensity track audible at a time (ambient ↔ tense ↔ danger), equal-power 2.5s handovers, hysteresis + 4s dwell against threshold flapping, and ducking under stingers and the soothe lullaby. The layered ideal returns if/when true aligned stems are produced (one composition, stripped mixes).

## Stem stack (per zone theme)
| Stem | Driven by | Example |
|---|---|---|
| **Ambient** | always on; time-of-day variant ([[mechanics/day-night-hideout]]) | wind, distant village, music box far away |
| **Tense** | dread 30–70, monster proximity | low strings, wrong-pitched lullaby fragments |
| **Danger** | dread > 70, combat, hollowing stage ≥ 2 ([[mechanics/hollowing-clock]]) | percussion, the Hunger's sub-bass |
| **Companion vocal** | fear/corruption of nearby companions ([[mechanics/companion-quirks]]) | whimpers, wrong-sounding purrs/growls |

Rules: crossfade by lerp through intermediate states (no hard cuts — escalation must feel *earned*); hideout scenes duck everything but ambient + a warm campfire layer (the safety contrast that makes dread legible); stingers stay separate one-shots (existing `GameEvents.horror_stinger`).

## Implementation
- **Option 1 (preferred)**: AdaptiSound addon (FOSS, Godot Asset Library) — declarative track stacks. Verify Godot 4.4 compatibility before adopting (addon pin rule, see AGENTS.md tech stack).
- **Option 2**: hand-rolled `AdaptiveAudio` autoload (~100 lines): one `AudioStreamPlayer` per stem on its own bus, `_process` lerps `volume_db` toward targets computed from `DreadManager` + `WorldState`.
- Stems must share BPM/key per zone theme; loop-cut in Audacity; OGG export.
- Mobile: 4 simultaneous OGG streams is cheap; keep stems mono except ambient.

## Accessibility
Horror-intensity slider scales tense/danger/vocal target volumes (never ambient — the world stays alive); "reduced dread" mode caps the danger stem.

## Asset plan (v1)
2 zone themes (playground/fringes, village edge) × 3 stems + 1 shared companion-vocal set + hideout warm layer = **8-10 short loops**. ACE-Step generation prompts go in [[art/imagine-prompts]]-style provenance notes (new `docs/art/audio-prompts.md` when work starts).

## Related
[[mechanics/horror-and-dread]] · [[mechanics/hollowing-clock]] · [[mechanics/day-night-hideout]] · [[design/ai-production-setup]] · [[design/feature-candidates-2026-06]]
