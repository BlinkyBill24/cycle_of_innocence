# ACE-Step audio prompts — Cycle of Innocence (AU1 stems)

Run at https://ace-step.io (or self-host). **All stems share A minor / 70 BPM** so they layer cleanly in the adaptive system ([[mechanics/adaptive-audio]]).

**Per prompt**: generate 60–90 s, instrumental, 3–5 candidates, pick the best. Don't worry about perfect loop points — drop the raw files into `assets/audio/stems/` with the names below and Claude Code will loop-trim them with ffmpeg.

## AU1a — `playground_ambient` (always on)
```
dark rural ambient, A minor, 70 bpm, sparse detuned music box notes, soft wind textures, distant wooden creaks, lonely village playground at dusk, very slow, atmospheric, instrumental, no drums, loopable background layer
```

## AU1b — `playground_tense` (dread 30–70)
```
horror tension underscore, A minor, 70 bpm, low sustained string drones, quiet dissonant swells, faint broken music box fragments, creeping unease without resolution, instrumental, no percussion, loopable middle layer
```

## AU1c — `playground_danger` (dread > 70 / combat)
```
horror chase underscore, A minor, 70 bpm with urgent double-time percussion feel, pounding low toms, deep sub-bass pulses, sharp string stabs, panicked momentum, instrumental, loopable intensity layer
```

**v2 (2026-06-12, playtest fix)**: v1 read as "reggae" to two independent
testers (failed threshold, [[playtest/2026-06/synthesis]]). Replaced with a
user-generated track from makebestmusic.com (share nwJvbzvO; raw MP3 kept in
`stems/raw/playground_danger_makebestmusic_2026-06-12.mp3`). 22.5s, converted
to OGG, RMS-matched to the v1 stem (×1.58 gain). ⚠️ Loop seam untrimmed (no
Audacity-style cut yet) and still an independent composition, not an aligned
stem — both go away in the audio content sprint (one composition, stripped
mixes).

## AU1d — `lullaby_motif` (the ritual song — soothe mechanic, stingers)
```
haunting simple childlike lullaby, solo music box, A minor, 70 bpm, slightly detuned and fragile, short repeating 8-bar melody, sparse, melancholic, instrumental
```

## AU1e — `hideout_warm` (campfire safety layer, optional but worth it)
```
warm intimate acoustic ambient, A minor, 70 bpm, soft fingerpicked guitar, gentle fire-crackle texture, tender but melancholic, safe haven feeling, instrumental, no drums, loopable
```

## AU2 — SFX (ChipTone, whenever convenient)
Claude Code will generate scripted placeholders first; replace at leisure: footsteps (grass/dirt), stick swing, hit thud, Briar dig, Briar whimper, Briar bark, toy-creak stinger, UI select/confirm.
