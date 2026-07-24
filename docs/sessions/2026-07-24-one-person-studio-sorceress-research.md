---
name: "Session 2026-07-24 — one-person studio + Sorceress research"
date: "2026-07-24"
tags: [session, research, pipeline]
branch: "docs/one-person-studio-sorceress-research"
commits: []
---

# Session 2026-07-24 — one-person studio + Sorceress research

## Focus

Analyse Min Choi’s “Grok 4.5 one-person game studio” X thread and evaluate
[Sorceress.games](https://sorceress.games/) for *Cycle of Innocence*. User chose
**Phase 0 docs-only** (option A): research note + ideas triage, no code bake-off.

## What I did
*(newest first)*

- Wrote integrated research note
  [[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]:
  claim scorecard, Sorceress tool map, adopt/reject matrix, hybrid pipeline
  only if bake-off wins, WizardGenie production reject, librarian flags.
- Captured three pipeline ideas in [[ideas]]: Content Studio Loop, agentic
  play-path smoke (Phase 1), Sorceress asset bake-off (Phase 2).
- Plan mode analysis of thread + sorceress.games; branch off `main`.

## Decisions made

- None locked in `docs/decisions/` — research only. Stance recorded in the note:
  - Steal the **studio loop**, not a new engine.
  - Sorceress = optional **Asset Studio** bake-off candidate, not stack replacement.
  - WizardGenie = **not** production (Godot 4.4 / Web locked).
  - PixelLab remains character/anim canonical until scored bake-off says otherwise.

## Bugs fixed

- None (docs session).

## Files touched

**New**:
- `docs/research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress.md`
- `docs/sessions/2026-07-24-one-person-studio-sorceress-research.md`

**Modified**:
- `docs/ideas.md` (three unsorted pipeline ideas)

## Next session

- **Phase 1:** `feature/agentic-playtest-smoke` — hollow-house key path MCP recipe.
- **Phase 2 (when ready to try Sorceress):** Briar pose bake-off A/B/C with scores;
  only then consider updating [[design/ai-production-setup]].
- STATE “Next” art (Briar stand-in poses) can use whichever arm wins.

## Related

- Source thread: https://x.com/minchoi/status/2079769568533229692
- https://sorceress.games/
- [[design/ai-production-setup]] · [[decisions/2026-06-10-sprite-tool-pixellab]]
