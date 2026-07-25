---
name: "Session 2026-07-25 — Sorceress SFX + AutoSprite trials"
date: "2026-07-25"
tags: [session, art, audio, pipeline, sorceress]
branch: "feature/sorceress-api-probe"
commits: []
---

# Session 2026-07-25 — Sorceress SFX + AutoSprite trials

## Focus

Two parallel stack trials (no auto-adopt):

1. **SFX** — three cues vs current bank  
2. **AutoSprite** — green still (Grok Imagine) → Imagine 1.5 walk → Corridor Key sheet  

## What I did
*(newest first)*

- AutoSprite full path OK: still → character → animate (12 cr) → key (4 cr) →
  11-frame 960px sheet. Previews at 48px. Agent rec: keep PixelLab for grids.
- SFX ×3 OK (`door_locked`, dig, stinger_toy) as mp3 under
  `sorceress_sfx_trial/`. Human listen gate before any bank swap.
- Extended `tools/sorceress_api.py`: `sfx`, `as-create`, `as-animate`, `as-key`,
  `call`, better job/media URL handling.
- Note: Sorceress hosts Grok Imagine stills + Imagine 1.5 video (user tip confirmed).

## Decisions made

- None that change production stack. Trials only; human scores pending for SFX.

## Bugs fixed

- None in game runtime.

## Files touched

**New:** trial folders under `assets/reference/bakeoff_2026-07-25/`, session journal.

**Modified:** `tools/sorceress_api.py`

## Next session

- Human: listen SFX pairs; score AutoSprite walk at game scale.  
- Only if clear wins: decision doc + optional convert-mp3→wav tooling.  
- Merge probe branch when happy with client+artifacts.

## Related

- [[decisions/2026-07-25-briar-pose-bakeoff]]
- arm_c API_PROBE + earlier cower score
