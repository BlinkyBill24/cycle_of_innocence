---
name: Player freezes while a modal is open
date: 2026-06-20
branch: fix/player-pause-while-modal
tags: [session, player, input, ui, pause, playtest]
---

# 2026-06-20 — Player holds still while the satchel (or any modal) is open

## The bug (playtest)
With the inventory open, pressing left/right to select an item ALSO walked Rowan in
the background. Two compounding causes:
1. The **player controller never listened to `exploration_paused`** — companions,
   the soothe prompt, and the hollowing clock all do, but the player didn't, so its
   `_physics_process` kept reading movement input while the satchel was open.
2. **Arrow keys are bound to BOTH `move_left/right` AND Godot's default
   `ui_left/right`** (menu focus nav), so one arrow press moved the satchel cursor
   *and* the character.

## The fix
Mirror the companion pattern in `player_controller.gd`: a `_paused` flag set on
`GameEvents.exploration_paused` / cleared on `exploration_resumed`. While paused,
`_physics_process` zeroes velocity, settles to idle, and **returns before reading any
gameplay input** — so menu navigation can't double as movement. Kept the existing
signal architecture (no `get_tree().paused`), matching the rest of the codebase.

**Bonus:** this was a latent bug everywhere `exploration_paused` fires — dialogue,
name entry, searchable clues. Rowan now holds still through all of them, not just the
satchel.

## Tests — suite 319 green, check-brain green
`test_player_pause.gd`: the pause flag flips on the signals; a paused player with
injected velocity is forced to a stop and does not drift; resuming returns normal
exploration. (The arrow-key double-bind itself is intended — WASD/arrows both move;
the fix is the player respecting the pause.)
