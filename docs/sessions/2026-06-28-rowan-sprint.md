---
name: 2026-06-28-rowan-sprint
date: 2026-06-28
tags: [session, player, movement, sprint, feature]
---

# 2026-06-28 — Sprint/run for Rowan

Added a sprint: hold **Shift** to run faster in **short bursts**, after which a forced
**recovery** is needed before sprinting again — **no stamina bar** (the limit is felt,
not a managed resource). Run *look* = the existing walk animation played faster (the
user chose the easy path; dedicated PixelLab run art logged as a follow-up).

## Mechanic
- Invisible reserve (`_sprint_charge`, starts `SPRINT_MAX_SECONDS = 1.6`). Holding sprint
  while moving drains it 1×; spending it fully sets `_sprint_locked` — Rowan drops to walk
  and can't sprint until the reserve refills to **full** (regen `0.5×` ⇒ ≈3.2 s recovery
  after a full burst; releasing early refills proportionally). Pure, unit-testable
  `PlayerController.sprint_step(charge, locked, wants, delta)`.
- Speed: `run_speed = 170` vs `move_speed = 110`, selected at the velocity line in the
  EXPLORING path (mirrors Briar's `run_speed` two-gait pattern).
- "Run" look: keep playing `walk_*`, boost `animated_sprite.speed_scale ×1.5`.

## The tricky part — one owner of `speed_scale`
Three systems wanted `speed_scale`: age (1.0/0.95/0.9), the dread FrameSpike (×0.8), and
now sprint (×1.5). Added **`_refresh_anim_speed()`** as the single owner that composes
`age × spike × sprint`. `age_morph.gd` now stores `age_speed_factor` and calls the
parent's helper instead of writing `speed_scale` directly (with a standalone fallback);
the spike's old save/restore (`_spike_prev_speed_scale`) was deleted in favour of calling
the helper. Net: ADULT sprint = 1.35, CHILD sprint during a spike = 1.2 — no clobbering.

## Files
- `scripts/player/player_controller.gd` — run_speed + SPRINT_* consts, sprint state,
  `sprint_step`/`_update_sprint`/`_set_sprinting`/`_refresh_anim_speed`, velocity select,
  `_set_sprinting(false)` on the paused/non-EXPLORING/soothe early-returns, spike rewire.
- `scripts/player/age_morph.gd` — `age_speed_factor` + defer to the player.
- `project.godot` — `sprint` action (physical Shift). *(Protected file — merge may need a
  web-UI click.)*
- `scripts/ui/touch_controls.gd` — held "RUN" `TouchActionButton` (Android parity).
- `tests/test_player_sprint.gd` — 11 tests (pure transition + composition + lifecycle).

## Verified
- `bash tools/run-tests.sh` → **399/399** (was 388 + 11 new).
- Live (runtime MCP, isolated player scene): Shift+move → velocity **110→170**,
  `speed_scale 1.5`, animation stays `walk_right`; held to exhaustion → `_sprint_locked`,
  back to 110 / scale 1.0; reserve refills and re-enables. No runtime errors.
  (Note: the main scene's intro leaves the player paused/DREAD_LOCK, so verify sprint from
  the isolated `scenes/player/player.tscn`, not mid-intro.)

## Follow-up
Dedicated PixelLab `run_*` art + sprint-raises-dread are logged in `docs/ideas.md`. The
four feel dials (run_speed, burst, regen, anim-scale) are left for human playtest tuning.
