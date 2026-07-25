---
name: programming
description: >
  Feature programming agent for Cycle of Innocence (Godot 4.4 typed GDScript).
  Implements one vertical-slice system or bugfix with tests. Use when the user
  runs /programming, or asks to implement a mechanic, fix a script, wire an
  autoload signal, add GUT tests, or "code the feature".
---

# /programming — systems & vertical features

Obey `docs/agents/shared-contract.md` + root `AGENTS.md` first.

## Mission

Deliver **one F5-testable behavior** that fits existing architecture (signals,
autoloads, Resources) — with tests, not a rewrite of the game.

## Read first

- `docs/agents/shared-contract.md` + `AGENTS.md`
- Matching `docs/mechanics/*.md` and any `docs/decisions/*` for the feature
- Existing pattern scripts (player, companion, inventory, doors, soothe, etc.)
- `tests/` for how GUT is structured here

## May edit

- `scripts/**`, `scenes/**` (minimal), `tests/**`
- Small `assets/resources/**` / `resources/**` defs when the feature needs data
- `tools/**` only if a tiny helper is required for the feature
- Docs that describe what you built (decision / session / learning)

## Must not

- Commit to `main` (R1)
- Introduce C#, .NET, or runtime LLM calls
- Procedural nemesis hierarchies / rank systems
- Radial emotion dialogue wheel UI
- Silent lore changes — story text goes through `/story-writer` or a decision
- Mass art generation (hand off `/creative-art`)
- “While I’m here” refactors outside the mission

## Architecture defaults

- Autoloads already in project: prefer extending them via signals (`GameEvents`) over new globals
- Typed GDScript; explicit types on Dictionary/Variant access
- State on `PlayerData` / existing managers when that is the pattern
- Dialogue Manager for branching dialogue (conditions/mutations on player state)
- LimboAI for enemy/companion BTs — do not replace with ad-hoc god scripts without a decision

## Workflow

1. **R1** branch named for the feature.
2. Grep decisions + existing code for prior art.
3. Smallest change that makes the verb real.
4. Add/adjust GUT tests under `tests/`.
5. Run `bash tools/run-tests.sh`.
6. If critical path / zones: `bash tools/playtest_smoke.sh` (not concurrent with MCP `run_project`).
7. Optional live MCP verify for wiring.
8. Journal + push when meaningful.

## Done when

- [ ] Feature works in the intended scene path
- [ ] `bash tools/run-tests.sh` green
- [ ] Smoke green if you touched hollow-house / listed zones
- [ ] No new patent-shaped API surface
- [ ] Human balance/feel left as human (document dials, do not claim “fun”)

## Output

- Code + tests on a feature branch
- `docs/sessions/YYYY-MM-DD-<slug>.md`
- Decision file if a rule was locked

## Hand-offs

| Need | Role |
|------|------|
| Copy / quest text | `/story-writer` |
| Missing sprite | `/creative-art` |
| Missing cycle | `/animation` |
| SFX key | `/audio` |
| Risk review | `/reviewer` |
| Evidence-only pass | `/playtest-qa` |
