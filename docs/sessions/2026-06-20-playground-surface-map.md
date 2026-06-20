---
name: Playground surface map (footsteps)
date: 2026-06-20
branch: feature/playground-surface-map
tags: [session, audio, surfaces, content-complete, playground]
---

# 2026-06-20 — Playground surface map (content-complete, item 1)

## What I did
The per-surface footstep *hook* shipped last pass with one rough `PlazaGravel`
zone. Authored the real surface map over the painted playground (no new mechanic):
- **PathHub** (`surface=path`) over the central dirt-path hub.
- **SandPit** (`surface=sand`) over the two framed sandboxes (bottom-right of the painting).
- **Wood** zones on the equipment — `WoodRoundabout`, `WoodSlide`, `WoodSwingLeft`,
  `WoodFrameRight`.
- `footstep_sound` now maps **`wood` → the hard (`footstep_gravel`) sample** (only
  two samples exist; a dedicated wood sample is a future audio pass). Unset ground
  stays grass.

## Tests
`test_footstep_surface.gd`: `wood`→hard mapping; the playground authors path/sand/
wood zones (and grass is never an authored zone). Suite **297 green**; check-brain green.

## ⚠ Note (honest)
The play equipment is **painted into the backdrop**, not placed as nodes, so I
positioned the wood/path/sand zones **by eye from the painting** — they're a good
first pass but exact alignment over the painted equipment is a quick **editor/F5
nudge** for you. The mechanism + surfaces are correct and tested.
