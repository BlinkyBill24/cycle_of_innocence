---
name: Day-Night Loop & Hideout
date: 2026-06-10
tags: [feature, mechanics, companions, horror, save-system]
status: planned
related_decisions: [[decisions/2026-06-10-new-features-and-ai-setup]]
---

# Day-Night Loop & Hideout (Safe-Camp)

## What it does
Splits play into a two-mode rhythm (Darkwood/Moonlighter): **day** = exploration, puzzles, scavenging, village reconnaissance in relative safety; **night** = dread spikes, corruption manifests visibly, certain monsters and ritual activity only at night. Between them sits the **hideout** — a safe-camp where Rowan tends companions, saves, and breathes. The hideout is also the game's emotional anchor: the found-family scenes happen at the campfire.

## Why it fits (prior art check, R3b)
- [[mechanics/horror-and-dread]] needs contrast to work — dread without safety flattens into noise. Mad Father/Ib safe-room contrast applied.
- [[characters/companions]] care actions (feed, soothe, play) currently have no *place*; the hideout gives them a diegetic home and a natural UI-free interaction space.
- ideas.md already captured "care mechanics with visible loyalty shifts" — this hosts them.
- Mobile-first: night→hideout→save is a natural session boundary ([[design/game-features]] §10 saves on "major story beats" — hideout rest becomes the canonical manual save).

## Flow
1. Time advances by **player action**, not real-time: each zone transition / major action ticks the day forward (dawn → day → dusk → night). A subtle palette shift (CanvasModulate) telegraphs it; no clock UI.
2. **Day**: standard exploration. Villagers/Wardens visible and avoidable. Most puzzles solvable.
3. **Dusk**: companions get restless (Briar whines toward camp — the game's "go home" cue, delivered by family instead of UI).
4. **Night**: dread floor rises (+20 baseline), vision radius shrinks ([[mechanics/vision-and-darkness]]), night-only monsters and ritual processions spawn (scaled by [[mechanics/hollowing-clock]] stage). High-corruption companions act *wrong* at night — the first place corruption shows.
5. **Hideout**: campfire scene. Available actions: feed/soothe/play (bond +, corruption −), inspect companions (their sprite state is the health UI), journal/memory review, **save**, sleep to dawn.
6. Choosing to push through the night instead of resting is always allowed — risk/reward, and some content is night-only (overhearing rituals, certain Stilled monsters wandering).

## Hideout progression
- Starts as a cold hollow under roots; small upgrades found (not crafted): a blanket, a firepit stone, Echo's perch, Storm's lean-to. Each upgrade is a story beat and slightly improves rest effects.
- Hideout can be **discovered** at Hollowing stage 3+ (Frenzy): forced relocation scene — even safety is provisional. One relocation max in v1.

## Data model
- `WorldState.time_of_day: enum {DAWN, DAY, DUSK, NIGHT}`, signal `time_advanced`.
- Hideout scene with care-interaction nodes driving existing `PlayerData.set_companion_bond/corruption`.
- Save anchored to hideout rest (plus existing auto-save on transitions).

## Edge cases
- Story sequences can pin time (no advancing mid-quest-chain).
- If all companions are dead/corrupted, the hideout scenes change to silence — the mechanic itself mourns ([[story/endings]] Failure path foreshadowing).
- Accessibility: "longer days" option for players who find night pressure stressful; horror-intensity slider dampens night audio/visuals, never the spawn rules.

## Mobile note
Palette-shift day cycle is shader-cheap; no real-time clock means no battery drain or interrupted-session unfairness.

## Related
- [[mechanics/horror-and-dread]] · [[mechanics/vision-and-darkness]] · [[mechanics/hollowing-clock]] · [[characters/companions]] · [[mechanics/inventory]]
