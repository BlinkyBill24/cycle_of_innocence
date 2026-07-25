---
name: "Session 2026-07-25 — Sorceress API probe"
date: "2026-07-25"
tags: [session, art, pipeline, sorceress, api]
branch: "feature/sorceress-api-probe"
commits: []
---

# Session 2026-07-25 — Sorceress API probe

## Focus

Mission: prove Sorceress Tool API with key on disk; one Briar pose vs Arm A
(test only). **Do not** auto-adopt stack.

## What I did
*(newest first)*

- `image_generate` (grok-imagine, cower prompt) → **402 Insufficient credits,
  balance: 0** — no asset written; score deferred.
- Built `tools/sorceress_api.py` (key from `~/.config/sorceress/api_key` or
  `SORCERESS_API_KEY`; ping / tools / image / job poll).
- Confirmed key present (mode 600). `ping` + `tools` catalog **OK**.
- Documented probe in `arm_c_sorceress/API_PROBE.md`; README pointer.
- Stack decision **unchanged** (no new adopt decision).

## Decisions made

- None that change production stack. Probe only.

## Bugs fixed

- None in game code.

## Files touched

**New**: `tools/sorceress_api.py`, `arm_c_sorceress/API_PROBE.md`, this journal.

**Modified**: `arm_c_sorceress/README.md`

## Next session

- Human: add Sorceress credits → re-run image command from API_PROBE.md.
- Score `cower_raw.png` vs Arm A; only then librarian/decision if C wins.
- Optional: extend client for AutoSprite tools (now live in catalog).

## Related

- [[decisions/2026-07-25-briar-pose-bakeoff]]
- [[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]
