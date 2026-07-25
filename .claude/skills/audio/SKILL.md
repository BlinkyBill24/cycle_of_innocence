---
name: audio
description: >
  Audio agent for Cycle of Innocence. SFX (and light adaptive music hooks) wired
  to existing Sfx keys and events — ElevenLabs or placeholders. Use when the user
  runs /audio, or asks for sound effects, stingers, door_locked, footsteps,
  crackle, or music stems.
---

# /audio — cues that fire on the right event

Obey `docs/agents/shared-contract.md` + root `AGENTS.md` first.

## Mission

Ship a **sound that plays on the correct game event**, under a stable key the
code already uses (or a new key wired end-to-end).

## Read first

- `scripts` / autoload `Sfx` (key table — keep filenames stable)
- Existing files in `assets/audio/sfx/`
- Adaptive audio docs if touching music stems
- Tools: `tools/gen_elevenlabs_sfx.py`, placeholder generator notes in design docs

## May edit

- `assets/audio/**` (WAV, etc.)
- `Sfx` key maps and one-line play call sites
- Adaptive audio hooks when the task is music/dread stems
- Prompt/notes for ElevenLabs generations (never commit API keys)

## Must not

- Commit API keys or `.env` secrets
- Rename keys casually (breaks callers) — alias or update all call sites
- Replace web-broken formats; prefer mono 16-bit WAV pipeline already used
- Huge music redesign without a decision

## Workflow

1. Find the **event** (locked door, dig, soothe, footstep surface, stinger).
2. Reuse an existing key if meaning matches; else add key + file + call.
3. Generate via ElevenLabs tool when credits allow; else placeholder with same filename.
4. Verify play path (code read + optional live MCP).
5. Web note: audio must remain export-safe (project already cares about web).

## Done when

- [ ] File exists at expected path
- [ ] Key in `Sfx` (or equivalent) matches callers
- [ ] Event triggers the sound (or test proves registration)
- [ ] Human gate: loudness/mix feel

## Output

- Audio asset + wiring + journal
- Credit/cost note if ElevenLabs used

## Hand-offs

| Need | Role |
|------|------|
| New dread beat timing | `/dread-director` |
| Surface map for footsteps | `/level-design` / `/programming` |
