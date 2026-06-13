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
  - ⚠️ **Codex gate** recommended on the ZoneManager/SaveManager autosave-path
    extension — running next.

## Related
[[mechanics/accessible-interiors]] · [[mechanics/zone-recontextualization]] ·
[[mechanics/hollowing-clock]] · [[mechanics/vision-and-darkness]]
