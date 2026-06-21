---
name: Flute — the gate that unlocks soothing
date: 2026-06-21
branch: feat/flute-soothe-gate
tags: [session, flute, mercy, soothe, gate, item, audio]
---

# 2026-06-21 — Flute: the gate that unlocks soothing

Delivers the flute as the single item that turns the EXISTING soothe ON. No soothe
resolution was built/changed — only the item, the gate, the wiring, and the audio.

## Soothe entry point (located, not built)
`PlayerController._start_soothe(target)`, reached from `_on_interact_pressed()` when a
spareable monster is in range (`_nearest_spareable_monster`). It EXISTS — so this goal
wired to it (did not build soothe resolution).

## What I built
- **Flute item** `resources/items/flute.tres` (KEY, non-consumed, non-discardable). New
  `ItemDef.grants_flag` — acquiring an item sets a one-time PlayerData story flag; the
  flute grants `flute_found`. Wired in `Inventory.add` (data-driven, reusable).
- **The gate** (`player_controller`): `_soothe_unlocked()` = `has_story_flag(flute_found)`.
  Pre-flute, `_on_interact_pressed` does NOT fire the soothe entry (near a monster does
  nothing → flee is what remains), and `_update_soothe_prompt` shows NOTHING (silent,
  diegetic — no "need the flute" text). No other input reaches soothe.
- **Play-to-soothe + audio**: `_start_soothe` now plays a diegetic **`flute`** SFX (a
  placeholder 4-note phrase synthesized to `assets/audio/sfx/flute.wav`, a one-shot — NOT
  an AdaptiveAudio stem), replacing the old `lullaby` cue. Reaching `_start_soothe` already
  means unlocked.
- **Persistence**: the unlock is a PlayerData story flag → survives save/load via SaveManager.
- **Test acquisition**: debug key **F** in `progression_test` grants the flute (+ a status line).

## Assumptions (goal said "correct in PR if wrong") — both HOLD
1. *Real-time active item, not a menu command* — ✔ "playing the flute" reuses the existing
   real-time interact-hold-to-soothe; acquiring the flute is the unlock (a flag), not a menu verb.
   **Design choice to confirm:** I did NOT make the flute a separately *equipped/selected* item with
   its own "use" input — the soothe verb already has an input (interact), so the flute UNLOCKS it
   rather than adding a parallel action. Easy to change to an equip-and-use flow if you'd rather.
2. *Targeting/range owned by the existing soothe* — ✔ reused `_nearest_spareable_monster` + `_start_soothe` unchanged.

## Tests — suite 354 green, check-brain green, Web export builds
`test_flute_gate.gd`: acquire unlocks + persists save/load; a pre-flute save stays locked;
no soothe fires pre-flute; the flute invokes the existing soothe (targets the monster);
playing it emits the `flute` sound.

## Out of scope (left alone, as scoped)
Soothe resolution/balance/targeting; the COMBAT side of the flute-gate (weapons-vs-monsters
pre-flute — tracked in [[ideas]], pairs with bare-fists-no-damage); final flute placement;
final flute melody; bare-fists rule; companions.
