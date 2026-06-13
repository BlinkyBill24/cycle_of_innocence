---
name: Session 2026-06-13 — animation retry for the 3 deferred chars
date: 2026-06-13
tags: [session, cycle-of-innocence, art, pixellab, animation]
branch: feature/charsheet-animations-retry
commits: []
---

# Session 2026-06-13 — animation retry for the 3 deferred characters

## Focus
Retry animating the 3 characters the first pass deferred (`storm_young`,
`briar_adult`, `storm_adult`) once PixelLab's animate service recovered.

## What I did
*(newest first)*
- **`storm_young` recovered → shipped (8/10 now animated).** Service was healthy;
  its record was only outage-blocked. Re-animated walk (filled the missing
  walk-west) → `download` → `sheets-pro`: `assets/sprites/companions/storm_young_32.png`
  + `assets/resources/companions/storm_young_frames.tres`.
- **`briar_adult` + `storm_adult` still blocked — deterministic PixelLab defect.**
  Survived **3 clean recreations + ~90 min of retries** in a healthy window: each
  record accepts an occasional single animate call then reverts to
  `404 "rotation image not found for direction: south"`, so movesets never fill.
  Same-template siblings (briar_corrupt, storm_young/corrupt) all work → not
  config. Diagnosed the earlier "all 3" failure as two separate causes: a
  transient service outage (cleared) + this per-record defect (persists).
- **Confirmed root cause of the lag:** newly-created PixelLab characters have a
  **multi-minute create→animate consistency lag** (rotations public before the
  animate backend can resolve them). My earlier windows raced it.

## Open / next
- **`briar_adult` + `storm_adult`** — try NOT-blind next: regenerate the *base*
  character from a FRONT concept crop or smaller `size` (both are bulky adult
  side-view quadrupeds — suspect a malformed south rotation at that framing), or
  file the two character ids with PixelLab. Base 8-dir sheets exist on main; only
  animated `.tres` outstanding.
- Scene integration of the now-8 `*_frames.tres` (still none wired).
- 5 non-character bibles (Echo egg/hatchling/adult/corrupt + grasping-roots) →
  object pipeline.

## Related
[[art/imagine-prompts]] · [[sessions/2026-06-13-charsheet-animations]]
