---
name: "Session 2026-07-24 — agentic playtest smoke"
date: "2026-07-24"
tags: [session, testing, agents]
branch: "feature/agentic-playtest-smoke"
commits: []
---

# Session 2026-07-24 — agentic playtest smoke

## Focus

Phase 1 of the one-person-studio adoption plan: a repeatable **playtest smoke**
so agents prove the hollow-house critical path still boots and is wired, instead
of only claiming it.

## What I did
*(newest first)*

- Verified live MCP walk: `run_project` hollow_house (background) → `run_script`
  (BuriedKey + InnerDoor + grant `hollow_key` → door unlocked) → screenshot
  `.mcp/screenshots/screenshot_1784917591_83926.png` → no SCRIPT ERROR →
  `stop_project`.
- `bash tools/playtest_smoke.sh` green: 6/6 GUT smoke tests + clean headless boots
  of playground_fringes, hollow_house, hollow_house_back, village_green.
- Added `tools/playtest_smoke.sh`, `tests/test_playtest_smoke_path.gd`,
  [[design/agentic-playtest-smoke]] runbook.
- Pushed earlier research branch `docs/one-person-studio-sorceress-research` to origin.

## Decisions made

- Smoke is **evidence for wiring/boot**, not dread/feel (human F5 still required).
- Do not run shell smoke concurrent with an active MCP `run_project` (bridge port fight).

## Bugs fixed

- None in game code. Shell script initially used invalid multi-value GUT `-gselect`
  (looked green while running zero tests) — fixed to single select + require
  "All tests passed".

## Files touched

**New**:
- `tools/playtest_smoke.sh`
- `tests/test_playtest_smoke_path.gd` (+ `.uid`)
- `docs/design/agentic-playtest-smoke.md`
- `docs/sessions/2026-07-24-agentic-playtest-smoke.md`

**Modified**:
- `docs/ideas.md` (Phase 1 done)

## Next session

- Phase 2 when wanted: Sorceress vs PixelLab/Imagine bake-off on Briar poses.
- Optional: add smoke to CI / completion checklist mention in AGENTS if desired.
- Human: merge research docs PR + this feature PR when ready.

## Related

- [[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]
- [[design/hollow-house-quest]]
