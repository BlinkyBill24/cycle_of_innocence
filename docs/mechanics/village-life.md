---
name: Village Life (Schedules + Overheard Gossip)
date: 2026-06-10
tags: [feature, mechanics, npc, narrative, post-slice]
status: implemented (v1 core 2026-06-11)
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Village Life — Routines You Watch, Lies You Overhear

> **Post-slice.** Designed now, built after the vertical slice ships.

## What it does
The village runs on **daily NPC routines** (Shadows of Doubt, scaled way down) and leaks its conspiracy through **proximity-overheard gossip** (Sorry We're Closed). Rowan — a child the village believes is dead — watches normal life continue from hiding. That's the cruelest beat in the bible, made playable.

## Why it fits (prior art check, R3b)
- [[story/bible]]: "villagers believe the ritual succeeded… the world moved on without you" and ideas.md already captured "Rowan overhears parents celebrating" — this systematizes it.
- Rides on systems already greenlit: time-of-day clock ([[mechanics/day-night-hideout]]), hollowing stages ([[mechanics/hollowing-clock]]), vision/stealth ([[mechanics/vision-and-darkness]]).

## A. Routines (≈10–15 named villagers)
- Each villager: 4 schedule slots (morning work / midday / evening social / night) → location + activity per slot. Plain data (`{npc_id: [{slot, zone, marker, activity}]}`), positions updated on time-advance — no pathfinding simulation while off-screen.
- Schedules shift by hollowing stage: stage 0 = idyllic routine; stage 2 = patrols, locked doors, parents walking children in groups; stage 3 = some schedules simply *stop* (their child was taken — an empty bench at the usual hour says it).
- Gameplay use: predict when a house is empty (exploration windows), when the chapel is full (safe passage elsewhere), which routes Wardens walk.

## B. Overheard gossip
- Eavesdrop zones (Area2D) near gathering spots; entering unseen plays ambient dialogue balloons (Dialogue Manager, no portrait/no choices).
- Content keyed to `hollowing_stage` + revelation flags: stage 0 relief ("thank the Lottery it wasn't ours"), stage 1 unease, stage 2 fear and blame, stage 3 horror. Some lines carry real intel (a name, a route, a ritual date) — gossip is a *systemic lore channel*, not flavor-only.
- Being SEEN while eavesdropping: villager reaction + suspicion (below).

## C. Suspicion (per-NPC, feeds the clock)
- `suspicion: float` per villager; raised by sightings, lowered by time. Crossing a threshold converts to hollowing **alarm points** ([[mechanics/hollowing-clock]] "player noise" rule) — the clock advances because *specific people* started talking.
- High-suspicion NPCs change their own gossip ("I saw something small moving by the fences…") — the player hears the net closing.

## Data model / tech
- `VillageState` (or part of WorldState autoload): schedules, suspicion dict, gossip pools per stage.
- NPC scene: idle/walk-to-marker only (NavigationAgent2D); LimboAI tree with 3 states (routine / notice / report).
- Save: suspicion + stopped-schedule flags.

## Scope guardrails
≤ 15 NPCs, one village zone, no economy/trading, no procedural names — every villager is authored (we need their children to have names).

## Implementation notes (2026-06-11, v1)
- `VillageState` autoload: SCHEDULES (5 authored villagers x 4 TimeOfDay slots, markers resolved per-zone via `marker_<name>` groups), STAGE2_OVERRIDES (children indoors), STAGE3_STOPPED (the empty bench), STAGE2_STARTED (Warden Oslo's playground search detail only exists once the village fears). Suspicion -> one alarm report per villager (25 pts); decays x0.7 per phase. Stage-keyed gossip pools with intel lines; caught eavesdropping multiplies notice rate x2.5 (`player_eavesdropping`).
- `Villager` NPC: walk/idle to slot markers, LOS notice + exclaim, absent when its marker isn't in the zone. Frames as @export on the instance ROOT (child overrides die in web export).
- `EavesdropZone`: floating ambient lines, no input lock. Village green zone: `scenes/zones/village_green.tscn` with real ZoneManager transitions.
- Tests: tests/test_village_state.gd + test_village_zone.gd.

## Related
[[mechanics/hollowing-clock]] · [[mechanics/day-night-hideout]] · [[mechanics/vision-and-darkness]] · [[story/bible]] · [[design/feature-candidates-2026-06]]
