---
name: New features from genre research + AI production setup
date: 2026-06-10
tags: [decision]
status: active
related_features: [[mechanics/encounters-mercy]], [[mechanics/hollowing-clock]], [[mechanics/day-night-hideout]], [[mechanics/vision-and-darkness]], [[design/ai-production-setup]]
related_bugs: []
supersedes: null
superseded_by: null
---

# New Features from Genre Research + AI Production Setup

## Context
With the story bible, mechanics docs, and progression core (PlayerData/AgeMorph) in place, we researched comparable games (Darkwood, Fear & Hunger, Undertale, OMORI, World of Horror, Children of Morta, Moonlighter, Eastward, The Last Guardian, Black & White) to find proven mechanics that fit a 2D top-down horror ARPG, and surveyed the AI tooling needed to actually finish the game solo (art, audio, dialogue, code agents, in-game AI, testing). Candidates were filtered against existing design docs per R3b — dread meter, bond/corruption, morality, NG+ echoes, and endings already exist and were not re-proposed.

## Decision
1. **Greenlight 4 new features** into the design vault (full specs in mechanics/):
   - [[mechanics/encounters-mercy]] — soothe/spare resolution (monsters are former sacrificed children); Domination as the Vessel mirror.
   - [[mechanics/hollowing-clock]] — 5-stage event-driven doom escalation mechanizing the bible's "delayed alarm".
   - [[mechanics/day-night-hideout]] — action-driven day/night loop + hideout safe-camp hosting companion care and saves.
   - [[mechanics/vision-and-darkness]] — facing-cone line-of-sight fog with companion senses (scent/overwatch/steadiness).
2. **AI production stack: FOSS-first** (see [[design/ai-production-setup]]); upgrade to paid tools only on concrete quality/volume walls. No runtime LLM in the shipped game.
3. **Tooling installed**: GUT v9.6.0 (+ `tests/` with PlayerData smoke tests, `tools/run-tests.sh`), LimboAI v1.6.0 (GDExtension for Godot 4.4), Dialogue Manager v3.10.4, godot-mcp built at `~/godot-mcp` for Claude Code scene-tree access.
4. **Tech-stack change: Yarn Spinner → Dialogue Manager.** The official YarnSpinner-Godot addon is C#-only; the .NET Godot build cannot export to Web in 4.4, and Web (itch demo + NAS playtest loop) stays a target platform. Dialogue Manager is pure GDScript, MIT, actively maintained, and reads/writes PlayerData autoloads directly (no variable-sync layer). Existing docs' "$yarn_variable" notation maps 1:1 to Dialogue Manager state access.

## Alternatives
- **Coin-flip save/combat mechanics (Fear & Hunger)**: rejected — punishing RNG conflicts with the mobile audience and the bond-driven emotional core.
- **1-bit/severe palette constraint (World of Horror)**: rejected — 32×32 SNES-style identity already locked in art pipeline.
- **Turn-based combat (Eastward/OMORI)**: rejected — real-time Zelda/Mana combat is locked in the build plan.
- **Merchant/economy loop (Moonlighter)**: rejected — inventory doc explicitly keeps no economy in v1.
- **Yarn via .NET Godot**: rejected — loses Web export in 4.4, heavier Android builds.
- **GDYarn**: rejected — unmaintained since Jan 2024.
- **Paid AI stack (~$70/mo)**: deferred — FOSS path covers v1; revisit per-tool when a wall is hit.

## Consequences
- + Four interlocking systems give the vertical slice and full game their horror identity (cone × night × clock × mercy).
- + Dialogue runs on all three target platforms with zero sync code; agents get scene-tree access via godot-mcp.
- − Docs/AGENT_RULES/GROK references to "Yarn" need a sweep (done for locked-stack files; older design docs read "Yarn" as "dialogue system").
- − Four new systems are design-debt until the slice proves them; build order: vision cone → day/night → mercy → clock (clock last, it depends on world state).

## Implementation
- **Commits**: (this branch: `feature/ai-setup-and-new-features`)
- **Files**: `docs/mechanics/{encounters-mercy,hollowing-clock,day-night-hideout,vision-and-darkness}.md`, `docs/design/ai-production-setup.md`, `docs/design/game-features.md` (§14), `addons/{gut,limboai,dialogue_manager}/`, `tests/test_player_data.gd`, `tools/run-tests.sh`, `project.godot`
- **Verified**: `godot --headless --editor --quit` clean; GUT smoke tests pass headless.

## Lookback Questions
- Did the Hollowing clock create urgency without anxiety-treadmill feel in playtests?
- Did Dialogue Manager hold up for the full branching scope (choice matrix, $hollowing_stage gates)?
- Which paid-tool upgrade triggers actually fired?

## Related
- [[2026-06-09-cycle-of-innocence-build-plan]] · [[design/game-features]] · [[story/bible]]
