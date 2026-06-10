---
name: Companion Quirks (Diagnosable Behaviors)
date: 2026-06-10
tags: [feature, mechanics, companions, horror]
status: planned
related_decisions: "[[decisions/2026-06-10-recent-games-research-greenlight]]"
---

# Companion Quirks — Corruption You Can Diagnose

## What it does
Bond and corruption stop being invisible numbers: they manifest as **specific, persistent, diagnosable behaviors** (Pacific Drive's quirk system, applied to living family). The player learns to *read* their companions — and high corruption makes that reading unreliable, which is the horror.

## Why it fits (prior art check, R3b)
- [[characters/companions]] already specifies "visual & behavioral feedback" and refusal risk; quirks give that a concrete data model and gameplay loop instead of ambient flavor.
- ideas.md inbox had "companion refusal extension" (The Last Guardian) — quirks absorb and supersede it.
- Builds directly on `PlayerData.companions` (bond/corruption per id) and existing `bond_changed`/`corruption_changed` signals; LimboAI behavior trees consume quirk state as blackboard variables.

## Quirk model
Each quirk: `{id, companion, trigger, behavior, tell, truth_chance}` — acquired at bond/corruption thresholds, persisted per save.

Examples (v1 pool: ~4 per companion):
- **Briar / bond ≥ 60**: growls at "empty" corners that hide buried things — a TRUE ping ([[mechanics/vision-and-darkness]] scent system) the player must learn to trust.
- **Briar / corruption ≥ 40**: stares at Rowan a beat too long when given orders; at ≥ 70, occasionally "guards" things that aren't there.
- **Echo / corruption ≥ 50**: scout reports gain `truth_chance < 1.0` — occasional FALSE pings (an ambush that isn't there… or is the real one the lie?).
- **Echo / bond ≥ 70**: lands on Rowan's shoulder before dread spikes — early-warning tell.
- **Storm / bond < 30**: refuses narrow-path route types entirely (forces detours); whinnies at specific villagers (suspicion hint, feeds [[mechanics/village-life]]).

## Diagnosis & care loop
- Quirks are *not* announced. The player notices patterns; the journal lets them pin observed behaviors per companion (lightweight: 1 line per discovered quirk).
- Hideout care ([[mechanics/day-night-hideout]]) can soften corruption quirks (lower trigger frequency) but never silently removes them — earned trust changes behavior visibly, e.g. the too-long stare becomes a head-bump.
- Empath-path insight: high-bond + Innocent tier shows a subtle tell animation distinguishing true pings from corrupted ones; Vessel tier sees nothing wrong at all (the Hunger hides its work).

## Data model / tech
- `companions[id].quirks: Array[StringName]` + quirk resource defs (trigger conditions, behavior anim, truth_chance).
- LimboAI: quirk flags on the blackboard; behavior-tree branches per quirk (low effort — conditions on existing follow/assist trees).
- GameEvents: `quirk_acquired(companion_id, quirk_id)`, `quirk_expressed(companion_id, quirk_id)`.

## Edge cases
- Never let a false ping cause unavoidable death — false information costs resources/dread, not runs.
- Horror-intensity slider: quirk *behaviors* always play (mechanical), but the most disturbing expressions (corrupted staring, wrong-jointed movement) soften visually.
- Quirks freeze during cutscenes/dialogue.

## Related
[[characters/companions]] · [[mechanics/vision-and-darkness]] · [[mechanics/day-night-hideout]] · [[mechanics/interface-horror]] · [[design/feature-candidates-2026-06]]
