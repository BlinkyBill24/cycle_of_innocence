# Sorceress SFX trial vs current bank (2026-07-25)

**Goal:** Can Sorceress `sfx_generate` replace **new** ElevenLabs SFX work?  
**Not** auto-swapping live `assets/audio/sfx/*` into the game yet.

## Pairings

| Game key (current) | Current file | Sorceress trial file |
|--------------------|--------------|----------------------|
| `door_locked` | `assets/audio/sfx/door_locked.wav` | `door_locked_sorceress.mp3` |
| `dig` → briar dig | `assets/audio/sfx/briar_dig.wav` | `briar_dig_sorceress.mp3` |
| `stinger_toy` | `assets/audio/sfx/toy_creak_stinger.wav` | `stinger_toy_sorceress.mp3` |

Prompts used (targetDuration 2):

- locked wooden door rattle and metal bolt thunk…
- small dog digging dirt paws scraping soil…
- creepy wooden toy creak stinger…

## Agent notes (not a feel score)

| Cue | API | Size note | Import path |
|-----|-----|-----------|-------------|
| door_locked | OK | ~2.1 MB mp3 (much larger than 120 KB wav — likely longer/denser) | need mono 16-bit WAV + loudness match |
| dig | OK | ~320 KB mp3 | same |
| stinger | OK | ~320 KB mp3 | same |

Pipeline: `python3 tools/sorceress_api.py sfx "…" --duration 2 --out file.mp3`  
Then convert/trim/normalize before touching `Sfx.gd` keys.

## Human score (you fill 0–5)

Listen **current .wav** then **Sorceress .mp3** at game volume.

| Criterion | door | dig | stinger |
|-----------|------|-----|---------|
| Clarity in mix |  |  |  |
| Tone fit (horror / toy / dirt) |  |  |  |
| Length / attack |  |  |  |
| Prefer for *new* SFX |  |  |  |

## Human scores (2026-07-25)

| Cue | Human call |
|-----|------------|
| `stinger_toy` | **Sorceress better than current** — prefer for next bank swap |
| door / dig | not called out; leave current until re-listen |

**Follow-up (not this merge):** convert `stinger_toy_sorceress.mp3` → mono 16-bit WAV, replace `toy_creak_stinger.wav` / keep `Sfx.gd` key `stinger_toy`.

## Stack status

ElevenLabs **not removed**. ChipTone/sfxr still fine for simple UI. Sorceress SFX approved as **source for at least stinger** after convert.
