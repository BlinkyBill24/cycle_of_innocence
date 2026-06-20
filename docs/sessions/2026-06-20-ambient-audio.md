---
name: Ambient + event sound wiring (crickets / owl / campfire)
date: 2026-06-20
branch: feature/ambient-audio
tags: [session, audio, wiring-pass]
---

# 2026-06-20 — Ambient + event sounds (Wiring & Audibility pass, item 3)

## Audit first (flag-don't-fake)
Much of this item was **already wired** (the goal's premise was stale):
- **Monster sounds** — `enemy_base.gd` already plays `monster_creep` (stalk on
  notice), `monster_attack` (lunge), `monster_hurt`. ✅ already done.
- **Doom bell** — `HollowingClock._world_lurches → _ring_bells(stage)` already
  tolls `bell_toll` once per stage reached (countable, respects no-dialogue /
  no-hideout timing). ✅ already done.

## What I newly wired
- **`Sfx.played(name)` signal** — additive; makes audible wiring testable.
- **Crickets night bed** — a quiet always-on looping crickets player in
  `AdaptiveAudio` (under the score; `finished→play` reconnect so it loops even if
  the import flag is missed). Loop-enabled `crickets.wav.import`.
- **Owl stinger** — occasional atmospheric owl in `AdaptiveAudio._process`, gated
  by a pure `owl_due(timer, next, in_hideout, active)` — silent in the hideout and
  while danger owns the channel.
- **Campfire crackle** — looping `AudioStreamPlayer2D` on the Hideout fire in
  `playground_fringes.tscn` (`campfire_crackle.wav` import was already loop-enabled).

## Tests
`test_ambient_audio.gd` (4): bell tolls on a stage advance; monster lunge plays
`monster_attack`; `owl_due` rules (gap / hideout / danger); the campfire crackle
node is wired + autoplaying. Suite **284 green**; check-brain green. Actual audio
playback is an F5 check.

## Notes
- No day/night system in the slice (out of scope), so the crickets bed is a
  quiet always-on dusk ambience rather than time-gated.
