---
name: Session 2026-06-13 — character-sheet animation pass
date: 2026-06-13
tags: [session, cycle-of-innocence, art, pixellab, animation]
branch: feature/charsheet-animations
commits: []
---

# Session 2026-06-13 — character-sheet animation pass

## Focus
Turn the 10 batch-3 PixelLab base characters (8-dir rotations) into animated
sprite sheets + `SpriteFrames` `.tres`, on an isolated worktree so a parallel
session could use `game/test`.

## What I did
*(newest first)*
- **Animation pass — 7/10 delivered game-ready.** Authored `ANIMATIONS` +
  `SHEET_ROWS` for all 10 in `tools/pixellab_v2.py` (walk·idle·attack·hurt +
  signatures), ran `animate → download → sheets-pro`. Shipped sheets + `.tres`:
  `rowan_teen`, `rowan_adult`, `briar_corrupt`, `storm_corrupt`, `crawler`,
  `ghost_girl`, `evil_warden`. Horse motion uses v3 `action_description`
  (no horse template listing). Full recipe in [[art/imagine-prompts]].
- **3 deferred — PixelLab `animate-character` backend degradation** (not config):
  `briar_adult`, `storm_adult` (0 anims), `storm_young` (walk-west only).
  `404 "rotation image not found for direction: south"` despite valid, fetchable
  rotations; reproduced across two recreations + ~25 min retries with the
  generation counter **frozen** → service-side. **Retry when it recovers:**
  `animate --only <char>` → `download` → `sheets-pro` (resumes via state).
- **Pipeline hardening:** `animate()` retries transient 404/5xx; `download()`
  skips a wedged char instead of aborting; `pro_anim_map()` tolerates a missing
  animations dir; `preview()`/`_fetch_frame()` send a browser UA (Backblaze 403).
- **Isolation:** ran in worktree `.claude/worktrees/charsheet-animations` off a
  fresh branch; `game/test` stayed on clean `main` for the parallel session.

## Open / next
- **Re-run the 3 deferred** once PixelLab's animate service recovers (one-liner
  per char; tool resumes). Then their `.tres` complete the set.
- **Scene integration:** wire the 7 (now 10) `*_frames.tres` into player /
  companion / enemy scenes — none are referenced yet.
- **5 non-character bibles** (Echo egg/hatchling/adult/corrupt + grasping-roots)
  still need the object pipeline (`create_map_object` / `animate_object`).
- Minor: a stray `_probe` animation exists on storm_adult (harmless, not in any
  sheet) — delete on next account cleanup.

## Related
[[art/imagine-prompts]] · [[sessions/2026-06-13-bible-charsheets]] · [[characters/companions]]
