---
name: "Session 2026-07-25 — Stinger Sorceress bank swap"
date: "2026-07-25"
tags: [session, audio, sorceress]
branch: "fix/stinger-toy-sorceress"
commits: []
---

# Session 2026-07-25 — Stinger Sorceress bank swap

## Focus

Bite 2: ship the human-preferred Sorceress stinger into the live SFX bank
without renaming the `stinger_toy` key.

## What I did
*(newest first)*

- Converted `stinger_toy_sorceress.mp3` → mono s16le 44.1 kHz WAV (gstreamer),
  peak-normalized to ~0.8, wrote over `assets/audio/sfx/toy_creak_stinger.wav`.
- `Sfx.gd` path/key unchanged (`stinger_toy` → same filename).
- Noted DONE in sfx trial README.

## Decisions made

- None (implements human score from Sorceress SFX trial).

## Bugs fixed

- None.

## Files touched

**Modified:** `toy_creak_stinger.wav`, trial README, this journal.

## Next session

- Human F5: stinger volume/mix on dread beat / locked-door era uses.
- Bite 3: place berries.

## Related

- [[sessions/2026-07-25-sorceress-sfx-autosprite-trials]]
