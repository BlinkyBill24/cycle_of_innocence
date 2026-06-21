# Session — Briar puppy bark (real SFX swap)

Branch: `feat/briar-puppy-bark`.

## What changed (plain language)

Swapped in the **new puppy-stage bark** the human recorded/sourced for Briar.
The file `briar_bark.wav` is replaced in place, so the game's `&"bark"` sound key
keeps pointing at it — no code change needed.

## Detail (optional)

- Source: `~/Downloads/Small_young_puppy_ba_#2-1782057238940.wav` (stereo, 48 kHz, ~2.0s).
- Converted to the project's SFX convention: **mono 16-bit** (downmixed L/R average),
  peak-normalized to ~-1 dBFS so it sits at library loudness. Kept 48 kHz; Godot
  resamples on playback.
- Re-imported; full suite still **377 pass** (the `Sfx` autoload preloads this file,
  so a bad WAV would fail every test — green proves it loads). `check-brain` clean.
- Note: the per-bark trim `&"bark": -8.0` in `sfx.gd` is unchanged. If the new puppy
  bark feels too quiet/loud in-game, that's the one number to nudge (human ear call).
