---
name: 2026-06-28-tell-and-door-feedback-fixes
date: 2026-06-28
tags: [session, fix, briar, doors, ui, art, audio]
---

# 2026-06-28 — Fixes for the two diagnosed feedback gaps

Follow-up to [[2026-06-28-godot-runtime-diagnostics]]. Both issues were diagnosed
as *legibility/feel*, not wiring — so these are the legibility/feel fixes. Verified
live with the runtime MCP server + 388/388 GUT tests green.

## Fix 1 — Briar's seek/bark "tell" (the "yellow blob")
The alert mark was a 6×8 px pale-yellow glyph with **no outline** — illegible.
- Rewrote `make_exclaim()` in `tools/gen_ui_icons.py`: a **10×14 bold "!"** — a
  straight chunky stem + a square dot, vivid alert-yellow (255,205,60) with a
  lighter top-left bevel highlight (255,240,150) and a full **8-neighbour dark
  outline** (40,22,10). Regenerated `assets/sprites/ui/exclaim.png` and reimported.
- `companion_base.gd._show_exclaim()`: nudged the spawn from y=-22 to **y=-24** so
  the taller mark clears the head. Scale stays 2× (→ 20×26 px on screen, crisp
  integer-scaled pixels). Used by both `_seek` (TELL phase) and `_bark`.
- Verified: 16× static preview reads as a clean "!"; live spawn confirmed at the
  right node/size earlier. A pristine in-game action shot wasn't worth chasing —
  the intro naming screen pauses the world and pins the framing.

## Fix 2 — Locked door "no feedback" (silent + non-reactive)
`trigger()` blocked correctly and showed a legible label, but it was **silent** and
the label was already on-screen from `_on_body_entered`, so pressing interact looked
like a dud.
- `door_transition.gd`: added `_reject_feedback()` — plays a "locked" thunk
  (`Sfx.play(&"stinger_toy", -6.0)`, toy-creak stand-in; no dedicated locked SFX
  yet) and gives the reason label a short **horizontal shake + alarm-red flash** so
  the press is acknowledged. Debounced via `_reject_cooldown` (0.4 s, decremented in
  `_physics_process`) so a mashed key doesn't stack tweens/sounds. Tween guarded by
  `is_inside_tree()` for headless safety.
- Called from `trigger()`'s locked branch (so it fires on the interact press / on a
  locked ENTER contact), after `_show_prompt(locked_reason)`.
- Verified live on `hollow_house.tscn` InnerDoor: `trigger()` still returns false,
  `_reject_cooldown` armed 0→0.4, label caught mid-flash reddish, second immediate
  press debounced, no runtime errors (Sfx fired clean).

## Tests
`bash tools/run-tests.sh` → **388/388 pass**. The locked-door test
(`test_accessible_interiors.test_locked_door_blocks_and_queues_nothing`) adds the
door to the tree before `trigger()`, so the new tween/Sfx path runs headless without
crashing and still asserts the false return.

## Deferred / notes
- No dedicated "locked" SFX exists — `stinger_toy` stands in. A bespoke
  latch-rattle would read better; folded into the audio backlog, not done here.
- The 2 stale-UID warnings in `playground_fringes.tscn` still surface on boot
  (separate cleanup-tail chore via `update_project_uids`).
- Briar art on `art/briar-puppy-versions` is untouched (parallel work).
