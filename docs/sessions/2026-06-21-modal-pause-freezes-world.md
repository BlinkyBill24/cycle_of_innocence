---
name: A modal freezes the whole world (monsters + journal)
date: 2026-06-21
branch: fix/modal-pause-freezes-world
tags: [session, pause, enemies, journal, ui, playtest]
---

# 2026-06-21 — Modals freeze the whole world

Follow-up to the player-pause fix. Two playtest questions:

## Q1 — "monsters still move when inventory is open, on purpose?" → NO, fixed
Enemies never listened to `exploration_paused` at all (only the player and
companions did). Fix in `enemy_base.gd`: a `_paused` flag set on
`exploration_paused` / cleared on `exploration_resumed`; on pause it **stops the
body (zero velocity, `_physics_process` early-returns) AND deactivates the HSM**
(`hsm.set_active(false)`) so the monster can't chase, lunge, or animate from under a
menu. Resumes cleanly. This is a *fuller* freeze than the companion pattern (which
only stops because it follows the now-frozen player).

## Q2 — "should the journal pause too?" → YES (consistency), done
The journal panel **emitted no pause signal at all**, so opening it froze nothing.
Made `journal_panel.gd` mirror the satchel: emit `exploration_paused` on open /
`exploration_resumed` on close (strict pairing), and **yield to a foreign pause**
(dialogue / the satchel) without stealing the resume. So reading the journal now
freezes the world too — you can't be chased or hit while reading.

Design note: pausing on the journal is a judgment call (it's a reading view, like the
satchel) — easily reverted if you'd rather the journal stay real-time.

## Tests — suite 322 green, check-brain green
- `test_enemy_base.gd`: a paused monster with injected velocity is forced to a stop,
  doesn't drift, and its HSM deactivates + reactivates on resume.
- `test_journal_pause.gd`: opening emits pause / closing emits resume; a foreign pause
  makes the journal yield without a double-resume.

## Coverage now
Player ✓ (prior fix), companions ✓ (follow the frozen player), **enemies ✓ (this)**,
hollowing clock ✓, soothe prompt ✓ — and the satchel, dialogue, name entry, searchable
clues, **and now the journal** all trigger the freeze.
