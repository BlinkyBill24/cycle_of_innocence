---
name: Cycle of Innocence — Phased Build Plan
date: 2026-06-09
tags: [decision, build-plan, cycle-of-innocence, preproduction]
status: active
related_features: []
related_bugs: []
supersedes: null
superseded_by: null
---

# Cycle of Innocence — Phased Build Plan (Approved)

## Context

User requested a complete, phased Grok Build plan in Plan Mode for a 2D top-down action-adventure RPG blending Zelda/Mana/Terranigma gameplay with Super Metroid/Silent Hill/Alien horror dread, Attack on Titan-style conspiracy twists and escalating revelations, and Fable-style protagonist life progression (child → adult with choice-driven appearance, personality, relationships, and world reactivity).

**Prior art (R3b)**: Full grep + reads of `../docs/decisions/`, learnings, ideas, sessions, handbook, and sibling `../rpg-adventure/GROK.md` + godot/ showed the existing project vision was a cozy non-combat 3D pixel diorama puzzle game ("Echoes of the Verdant Realm" / Mote, with vine/season mechanics). The 2D rpg-adventure/ was a room-based prototype with good engineering patterns but "pure gameplay" / forgiving tone and no horror or deep narrative.

This plan (and the project in `test/`) is a **major pivot** to a dark, story-heavy title. Explicit user revision during plan review: no Mote reuse, protagonist is an escaped child sacrifice, primary companions are rescueable/raiseable animals (dog, bird, horse...) with raising, bond, and corruption mechanics.

Clarifications locked via ask_user_question: title "Cycle of Innocence", develop in current workspace `test/`, real-time action combat, Yarn Spinner for dialogue.

The full detailed plan (phases, pipelines, code sketches, risk mitigation, verification, next steps) was written to the Grok session plan file and is the source of truth.

## Decision

Ship **Cycle of Innocence** following the complete 7-phase build plan (Phase 0 pre-prod through Phase 6 release prep) as documented in the session plan artifact.

Key commitments:
- Develop in `test/` (project root for this title for now).
- Create and maintain local Obsidian vault at `docs/` (inside this directory) + `GROK.md` at root (modeled on sibling + parent rules).
- Reuse only low-level patterns from siblings (2D player controller, autoloads, room/zone, touch/input, pixel pipeline, Imagine tools). No Mote mechanics or tone.
- Protagonist = escaped sacrifice. Animal companions as core progression, utility, and emotional stakes (with growth + possible corruption).
- Real-time action combat + Yarn branching narrative with age/morality/bond variables.
- Strict vertical slices, AI leverage (image_gen, subagents, graphify, skills), scope control via gates, and full adherence to monorepo rules (branch, Obsidian consult, journals, ideas, status.py).

See the full plan for detailed milestones per phase, code examples, asset prompts, architecture diagram, and verification steps.

## Alternatives
- Evolve the existing cozy Mote vision or rpg-adventure tone directly — rejected (user requested this specific dark conspiracy + animal bonds + escaped sacrifice concept).
- Pure custom dialogue system (no Yarn) — rejected (Yarn chosen for writer velocity on heavy branching reveals).
- Human party as primary bonds — revised per user feedback to animal companions only.

## Consequences

**Positive**
- Delivers the exact ambitious vision requested (horror + twists + Fable progression + animal found-family).
- Reuses proven 2D Godot cross-platform engineering from the monorepo while starting fresh on story/mechanics.
- Local vault + GROK.md + documented use of hooks/agents gives strong memory and AI acceleration for solo dev.
- Early vertical slice + gates protect against scope creep on art (age + animal variants) and writing.

**Negative / trade-offs**
- Significant tonal departure from prior project work (Mote pre-prod just completed GREEN).
- Higher emotional/art/writing scope than the previous cozy prototype (mitigated by focused 2–3 animals, Yarn, phased approach).
- Must maintain discipline on "within this directory" vault while still feeding parent docs/ per R3.

## Implementation
- **Branch**: `feature/cycle-of-innocence` (created; all work here).
- **Files** (initial from this session):
  - `GROK.md` (root)
  - `docs/` (full local vault: home.md, ideas.md, _templates/, decisions/, sessions/...)
  - `docs/decisions/2026-06-09-cycle-of-innocence-build-plan.md` (this doc)
  - `docs/sessions/2026-06-09.md` (setup journal)
- The complete actionable plan (phases 0–6, pipelines, snippets, next steps) lives in the Grok session plan file and should be referenced / partially mirrored here.
- Next: engine spike (port player + basic zone + age stub), art spike (first bibles via image_gen), Yarn first nodes, persist more as work progresses.

**Verified**: Plan approved via exit_plan_mode after exploration, clarification questions, and user revision for animals + escaped-sacrifice protagonist + no Mote reuse.

## Lookback Questions
- Did the animal companion focus (raising + corruption) deliver the intended emotional horror weight?
- Did the first vertical slice (escape + one companion + one horror beat) land the "loss of innocence + conspiracy seed" tone?
- How well did Yarn variable sync + PlayerData handle age + bond + revelation state across platforms?
- Did we keep scope under control (2–3 animals, focused campaign)?

## Related
- [[home]]
- [[../../docs/home]]
- [[../../docs/decisions/2026-04-06-game-vision-echoes-verdant-realm]] (prior vision — not reused)
- [[../../rpg-adventure/GROK.md]] (patterns source)
- Full session plan artifact (Grok)
- Parent [[../../CLAUDE.md]]
