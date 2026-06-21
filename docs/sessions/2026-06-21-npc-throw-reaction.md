---
name: Throw-at-NPC reaction (Marta showcase)
date: 2026-06-21
branch: feature/npc-throw-reaction
tags: [session, npc, village, story, reaction, probe, throw]
---

# 2026-06-21 — Throw-at-NPC reaction: ONE showcase NPC (Marta)

The story half of the throw verb: hit a PERSON and they react — specific to who they
are and their CURRENT state. Built for exactly one NPC (Marta), to validate before scaling.

## What I built
- **Shared `thrown` marker**: `ThrownProjectile` (slingshot) and the `ThrowableObject`
  Hitbox now join group `thrown` — the single thing NPC reactions key off (a melee swing
  is NOT in it, so it never provokes).
- **`NpcThrowReaction`** (Area2D component, on Marta only): detects a `thrown` Hitbox on
  the hit_hurt layer and fires a **scripted, state-keyed** reaction:
  - `choose_reaction_title(stage, suspicion)` (pure) → `calm` / `wary` / `afraid` —
    calm early, afraid once HollowingClock stage or VillageState suspicion climb.
  - Line authored in `resources/dialogue/marta_throw_reaction.dialogue` (Dialogue
    Manager), shown as a **diegetic floating balloon** + a body-language **flinch**.
  - Provocation consequences: **raises VillageState suspicion** (persisted via SaveManager)
    and nudges PlayerData morality toward Vessel; announces `GameEvents.npc_reacted_to_throw`.
  - A short refire cooldown = one rock, one reaction (debounce, NOT memory).
- Attached to **Marta** in `village_green.tscn`. Every other villager (Pieter, the warden…)
  ignores thrown objects — by design.

## ⚠ HARD GUARDRAIL — held
The reaction is a FIXED table keyed to identity + CURRENT state only. It does **not**
learn, remember across encounters, build a grudge, or pursue — no procedural/"nemesis"
behaviour. The line varies by present stage/suspicion, never by how many times you've
thrown. (Raising village suspicion is the existing village-notices system, not a personal
vendetta that hunts Rowan.)

## Interpretation note (flag)
The goal said "Dialogue Manager balloon line" AND "diegetic, no UI popup." Those pull
opposite ways (the project's DM balloon is a modal popup). I resolved it as: lines
**authored in a Dialogue Manager .dialogue**, presented as a **diegetic floating balloon**
(non-blocking) — best fit for "no UI popup, balloon + body language." Easy to switch to the
modal DM balloon if you prefer.

## Tests — suite 337 green, check-brain green
`test_npc_throw_reaction.gd`: a thrown hit fires the reaction; a melee swing does NOT;
the title varies across states; the authored calm/afraid lines differ; the hit raises
suspicion and it survives save/load; it hardens morality; a plain villager has no reaction
component (regression). Also tightened `test_village_state` (npc_id alone no longer implies
"villager instance needing frames").

## Flags
- **Reaction lines are DRAFT** (creative bible content) — refine Marta's calm/wary/afraid.
- **VALIDATE BEFORE SCALING**: this is a probe → playtest whether the reaction reads as
  meaningful before authoring more reactive NPCs. Captured in [[ideas]].
- The referenced **physical-interaction research note still doesn't exist** in `docs/research/`.
