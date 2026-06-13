---
name: "Session 2026-06-13 — accessible interiors"
date: "2026-06-13"
tags: [session, cycle-of-innocence, systems]
branch: worktree-accessible-interiors
commits: []
---

# Session 2026-06-13 — accessible interiors

## Focus
Build the Terranigma-model interiors system (enter houses/huts/caves, move
between floors) on the existing ZoneManager + ZoneRoot rails.

## What I did
*(newest first)*
- **Playtest fixes + real placement** (branch `chore/export-localhost`, off
  merged main; web build re-exported to localhost:8081):
  - **Entrance moved to a real village house**: the cottage is now entered via
    a `DoorTransition` on `PropCottageA` (Marta's house) in `village_green` —
    it already lines up with the interior's `marker_marta` spot. Added a
    `spawn_from_cottage` return marker; cottage `ExitDoor` repointed to
    `village_green`. The temporary playground test door was reverted.
  - **Stairs were unfindable** (invisible `Area2D`s sitting in the graybox
    wall-band): added `stairs_down`/`stairs_up` placeholder sprites and moved
    `StairsDown` onto open floor `(120,-10)` with a matching arrival marker, so
    the prompts trigger where the player can see to stand.
  - **Dark-interior prompt fix**: the door prompt rendered in world space, so
    the basement `DarkTint` crushed it to black. Moved it to a follow_viewport
    `CanvasLayer` (separate canvas, immune to world CanvasModulate).
  - Suite **250** green; reach: playground → walk west edge → village → Marta's
    house (NW) → cottage → stairs → basement → up → exit back to the village.
- **Accessible Interiors system** (suite 247, full enter→floor→save smoke green):
  built on the *existing* transition/camera rails per the goal, not a parallel
  mechanism. Spec → [[mechanics/accessible-interiors]].
  - **ZoneManager extension**: `go_to_scene(path, spawn_id)` for arbitrary
    interior scenes (not bloating the `ZONE_SCENES` const); `spawn_<id>` marker
    resolution + `restore_position`; `request_transition` gained an optional
    `spawn_id`. `place_player_at_entry` priority: restore_position > spawn_<id>
    > legacy `entry_from_<prev>`/`entry_default` (back-compat preserved).
    `ZoneRoot` records `current_scene_path` on enter.
  - **`DoorTransition`** (one component for door→interior, stairs→floor,
    exit→world): Area2D, INTERACT/ENTER modes, `target_scene` PackedScene OR
    `target_scene_path` string (string avoids circular floor↔floor loads),
    `locked`+reason, floating prompt.
  - **`InteriorRoot extends ZoneRoot`**: per-floor `dread_baseline` (registers a
    DreadManager zone level on enter, clears on `_exit_tree`); inherits the
    camera-clamp-per-GroundBackdrop invariant free.
  - **SaveManager floor persistence**: saves `scene_path` + `player_pos`; loads
    back into the saved floor at the exact spot (basement save reloads in the
    basement, not the world).
  - **Reference cottage**: `cottage_ground.tscn` (exit→village, stairs→basement,
    a `recontext_monsters_are_children` node, a VillageState `marker_marta`) +
    `cottage_basement.tscn` (dread_baseline 45, occluder walls + ambient light).
    Graybox placeholder backdrops — real interior art is the PixelLab pipeline
    pass; collision/dressing is the user's editor pass.
  - **Tests**: 9 GUT (door locked/target, spawn-id/default/restore/legacy
    resolution, save-load floor round-trip) + a headless integration smoke
    driving real scene swaps (enter→basement→up + save/load-in-basement, all
    landing at correct spawns; dread floor 45 confirmed).
  - **Parallelization** (user asked): dispatched a background sub-agent to write
    the mechanics doc while I built the system (non-overlapping files).
  - ✅ **Codex gate** done (background `codex:rescue` agent). No critical
    findings; three should-fix one-shot-state-hygiene edge cases on the
    autosave path, all fixed on a fresh branch `fix/interiors-arrival-state`
    (the system branch was already merged):
    - **S1** `load_game` wipes stale `arriving_spawn`/`arriving_from`/
      `restore_position` up front, so a load fired mid-transition is steered
      only by `restore_position`.
    - **S2** `place_player_at_entry` consumes the one-shot state even when the
      arriving scene has no player node (new `_clear_arrival_state` helper),
      instead of early-returning and leaking it to the next load.
    - **S3** `go_to_scene` `_transition_pending` guard blocks a second trigger
      (double-press / two doors in a frame) from overwriting the in-flight
      spawn+path; cleared when placement lands.
    +3 GUT tests → **250 passing**; check-brain green. Pushed.

## Related
[[mechanics/accessible-interiors]] · [[mechanics/zone-recontextualization]] ·
[[mechanics/hollowing-clock]] · [[mechanics/vision-and-darkness]]
