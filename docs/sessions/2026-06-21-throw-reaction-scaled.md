---
name: Throw-reaction scaled to the village
date: 2026-06-21
branch: feature/scale-throw-reactions
tags: [session, npc, village, story, reaction, scale]
---

# 2026-06-21 — Scaled the throw-reaction to the village

The Marta probe read well in playtest, so the reaction is now rolled out — each NPC
reacts as THEMSELVES (their own authored lines), still scripted + state-keyed.

## System change
`NpcThrowReaction` gained `@export reaction_dialogue_path` — each reactive NPC points
at its own Dialogue Manager `.dialogue`. Marta keeps the default; everyone else sets
their own. The shared `choose_reaction_title(stage, suspicion)` still picks the slot
(calm/wary/afraid = early / clock-turning / net-closing); each NPC fills those slots
in-character.

## Authored reactions (draft bible voice)
- **Pieter** (a father): weary scolding -> "Whose boy are you?" -> "I don't know your
  face. Should I know your face?" (the delayed-alarm horror).
- **Elder Aldwin** (rite-keeper): a ritual admonishment -> "let me see you properly" ->
  "I have blessed that stubborn arm before." (recognition, NOT fear).
- **Warden Brek** (the watch): a bark -> "hands where I can see them" -> "I'll have your
  name and your house." (authority hardening to threat — words only, NO pursuit AI).
- **Lena** (a village child): "that's not how you play!" -> "why's everyone so
  frightened?" -> "Mama— MAMA!" (innocence to terror).
- **Warden Oslo** (the searcher, in the playground): "show yourself" -> "this ground is
  not for playing" -> "...A child. Here. They told us the ritual took." (the hunter
  realizing the sacrifice escaped).

## Guardrail — still held
Every reaction is a FIXED table keyed to the NPC's identity + CURRENT state. No
learning, memory, grudge, or pursuit — the warden's threat is a scripted bark, not a
behaviour change. Raising suspicion is the existing village-notices system.

## Tests — suite 340 green, check-brain green
`test_npc_throw_reaction.gd`: every authored NPC's calm/afraid lines are distinct; the
village wires >=5 reactive NPCs, each with its own dialogue. (Marta's existing tests
still pass — the default path is back-compatible.)

## Flags
- All new lines are DRAFT bible content — refine to taste (one .dialogue per NPC under
  `resources/dialogue/*_throw_reaction.dialogue`).
- The base villager prefab stays non-reactive; reactivity is opt-in per placed instance.
