---
name: 2026-06-28-briar-puppy-versions
date: 2026-06-28
tags: [session, art, briar, companions, decision]
---

# 2026-06-28 — Briar puppy art: preserved drafts + style decision

Picked up the week-old uncommitted Briar art on `art/briar-puppy-versions`
(569 files, never committed). Two purposes: stop the loss risk, and settle the
open style fork.

## What was already there (PixelLab generation pass)
Two puppy style versions of the **same normal pup**, off two Grok concept refs:
- **V1 (chunky/detailed)** — 64px source sheets, richly shaded.
- **V2 (simple/compact)** — 124px source (small dog within), flatter/icon-like.
Each: 4-direction sheets + draft animations (idle/walk/run/seek/growl full 4-dir;
dig/bark south+east) = 120 frames. Plus adult + corrupted 8-dir sheets, shared
style ref, and reproducibility `params.txt` + state JSON. Full detail in
`assets/companions/briar/PUPPY_VERSIONS_NOTES.md`.

## Done this session
- **Committed + pushed** the whole draft set to Forgejo (was at-risk uncommitted
  for a week). Generators `tools/briar_puppy_versions.py` + `briar_concept_variations.py`
  committed alongside.
- Rendered a **V1-vs-V2 side-by-side** (4-dir sheets + walk strip) to drive the call.
- **DECISION: V2 (simple/compact)** is the chosen style — reads clean at the game's
  ~32px in-world size; V1's detail muddies when shrunk. V1 kept in-branch as reference.
  Recorded at the top of PUPPY_VERSIONS_NOTES.md.

## NOT done — deliberately (manual, not headless)
The notes are explicit and I held the line: the next step is a **hand pixel-editor
pass on V2** — crop the dog out of the 124px canvas, snap to the game grid, clean up
the rough text-to-animate motion, fill/mirror the missing side directions for
dig/bark, rig the walk/run cycles — then build `SpriteFrames` and wire into
`scenes/companions/briar.tscn`. Agents are runtime/feel-blind on this; it's a human pass.

## Next
- Human: the V2 polish pass above.
- (This session continues to the locked-door SFX task next.)
