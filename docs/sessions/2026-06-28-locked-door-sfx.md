---
name: 2026-06-28-locked-door-sfx
date: 2026-06-28
tags: [session, audio, sfx, doors, elevenlabs]
---

# 2026-06-28 — Dedicated locked-door SFX

Replaced the `stinger_toy` (toy-creak) stand-in used by the locked-door feedback
fix ([[2026-06-28-tell-and-door-feedback-fixes]]) with a purpose-made sound.

## What changed
- **New SFX** `assets/audio/sfx/door_locked.wav` — generated via ElevenLabs
  (`tools/gen_elevenlabs_sfx.py`, new `door_locked` entry): "iron handle rattles +
  a heavy bolt thunk, the door shudders but does not open." 1.36 s mono 44.1 kHz.
  Envelope is front-loaded (rattle-thunk, then decay) — reads as a denied door.
- **Peak-normalize added to the generator.** ElevenLabs returns wildly inconsistent
  levels (this clip came back at ~18% peak; the old per-key dB trims like bark's
  -8 exist for the same reason). Added `normalize_peak()` (target 80%) into
  `generate()` so every newly-generated SFX gets consistent loudness at the source.
  Applied it to the already-generated `door_locked.wav` in place (→ 80% peak) to
  avoid spending another API credit.
- **Wired in:** `Sfx.gd` STREAMS gains `&"door_locked"`; `door_transition.gd`
  `_reject_feedback()` now plays `&"door_locked"` at -3 dB instead of `&"stinger_toy"`.

## Verified
- `bash tools/run-tests.sh` → **388/388 pass** (Sfx loads the new WAV).
- Live (runtime MCP server, `hollow_house.tscn` InnerDoor): trying the locked door
  emits `Sfx.played == "door_locked"` (stream loads as AudioStreamWAV), still
  returns false / blocks, no runtime errors.
- Note: a fresh headless `--import` logs a transient "no resource loaders" parse
  error because the Sfx autoload preloads the WAV before the import pass registers
  it; it resolves on the same run (tests immediately after pass). Normal for adding
  a preloaded asset — not a real failure.

## Backlog now clear
The "bespoke locked SFX" follow-up from the feedback-fix session is done.
