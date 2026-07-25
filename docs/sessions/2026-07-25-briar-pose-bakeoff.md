---
name: "Session 2026-07-25 — Briar pose bake-off"
date: "2026-07-25"
tags: [session, art, bakeoff, briar]
branch: "feature/briar-pose-bakeoff"
commits: []
---

# Session 2026-07-25 — Briar pose bake-off

## Focus

Phase 2: score **Grok Imagine vs PixelLab vs Sorceress** on Briar’s missing
stand-in poses (cower, dusk_press, head_bump, lie_down) and wire a winner.

## What I did
*(newest first)*

- Rebuilt `briar_v2_pup.png` + `briar_v2_frames.tres` with dedicated pose anims.
- Decision [[decisions/2026-07-25-briar-pose-bakeoff]]: **Arm A interim ship**;
  PixelLab stays multi-dir; Sorceress not adopted.
- Arm A: four Grok `image_edit` poses from V2 style+idle anchors → 48px cells.
- Arm B: PixelLab bitforge (64×64, low top-down, style+init) — style lock OK,
  **pose change failed** (all standing).
- Arm C: human recipe only (`arm_c_sorceress/README.md`) — no browser login in agent.
- Artifacts under `assets/reference/bakeoff_2026-07-25/` + compare sheet.

## Decisions made

- [[decisions/2026-07-25-briar-pose-bakeoff]]

## Bugs fixed

- PixelLab first attempt: init image size 124≠64; animate-with-text init type
  errors — fixed by resizing anchors; bitforge then succeeded (still pose-weak).

## Files touched

**New**: bake-off tree, decision, session journal, Arm C README, pose frame dirs.

**Modified**: `tools/build_briar_v2_spriteframes.py`, `briar_v2_pup.png`,
`briar_v2_frames.tres`, `docs/art/imagine-prompts.md`, `docs/ideas.md`,
`docs/design/ai-production-setup.md`.

## Next session

- Human F5: do fear/press/lie/head-bump read at game scale?
- Optional human Sorceress trial to complete Arm C scores.
- Hand polish Imagine drafts (projection + pixel edges) or PixelLab skeleton
  re-try for true multi-dir poses.
- Merge with playtest-smoke / research branches if still open.

## Related

- [[research/done/2026-07-24-one-person-ai-game-studio-claims-and-sorceress]]
- [[design/agentic-playtest-smoke]]
