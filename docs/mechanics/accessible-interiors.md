---
name: Accessible Interiors (Houses, Huts, Caves & Floors)
date: 2026-06-13
tags: [feature, mechanics, exploration]
status: implemented (2026-06-13, branch feature/accessible-interiors)
related: "[[mechanics/zone-recontextualization]] · [[mechanics/hollowing-clock]] · [[mechanics/vision-and-darkness]] · [[mechanics/day-night-hideout]] · [[mechanics/encounters-mercy]] · [[characters/companions]]"
---

# Accessible Interiors — Step Inside, Go Down a Floor

## What it does
The player can walk through a door/hut-mouth/cave-entrance into an **interior**, and move between **floors** (ground → basement → attic; surface → cave level) via stairs and ladders — the **Terranigma model**: exteriors and interiors are the same exploration loop, you just cross a threshold. Each interior **floor is its own scene**; thresholds are a single reusable `DoorTransition` node (door→interior, stairs→floor, exit→world). Saving inside a basement and reloading drops you back **in that basement, at the exact spot** — interiors are first-class, persistent space, not a cutscene.

## Why it fits (filter)
- **Exploration / replay**: gives the Zelda/Mana loop real interiority — a hut you couldn't enter at age-child becomes a recontext beat at teen, a locked cellar a [[mechanics/hollowing-clock]] doom payoff. Interiors are where authored secrets, keepsakes, and [[mechanics/encounters-mercy]] "old home" reveals live.
- **Horror**: the inside↔outside contrast is a dread instrument — a tended home decays dread, a cellar/cave raises a floor (`dread_baseline`). Darkness ([[mechanics/vision-and-darkness]]) is authored per-floor (ambient `PointLight2D` + `LightOccluder2D` walls).
- **Companion / story**: the found family crosses thresholds *together* (companions are repositioned beside Rowan on arrival, not left to sprint in); interiors anchor bond moments and shelter ([[mechanics/day-night-hideout]] hideout). Human NPCs (Marta) live in authored rooms via `marker_<name>` groups.

**Architecture decision (load-bearing):** interiors are their own **zone scenes, one scene per floor** — *not* sub-rooms inside an exterior scene. This preserves the `ZoneRoot` **camera-clamp-per-`GroundBackdrop` invariant**: each floor has its own backdrop, so the camera clamp (which stops the void past the painted edge from ever showing) "just works" with zero special-casing. Multi-room-in-one-scene would break that invariant; floors-as-scenes keeps it.

## Mechanism

**Components**
- **`scripts/world/door_transition.gd` — `DoorTransition` (`Area2D`)**: the one threshold component. Exports `target_scene`, `spawn_id` (default `&"default"`), `mode {INTERACT, ENTER}`, `locked` + `locked_reason`, `prompt_text`. `INTERACT` floats a `[E]` prompt while the player stands on it and triggers on the `interact` action; `ENTER` triggers on contact (seamless thresholds). `locked` blocks entry and floats a diegetic reason — restraint for buildings with **no authored interior** (flag, don't fake). `trigger()` returns `false` when locked; otherwise calls `ZoneManager.go_to_scene(target_path(), spawn_id)`. `target_path()` is pure/testable.
- **`scripts/world/interior_root.gd` — `InteriorRoot extends ZoneRoot`**: one interior floor. Inherits the camera-clamp + spawn placement unchanged. Adds only a per-floor `@export dread_baseline`: if `> 0` it `DreadManager.register_zone_level(zone_id, dread_baseline)` and emits `dread_zone_entered` on `_ready`; on `_exit_tree` it emits `dread_zone_exited` so the floor's dread never leaks into the world or the next floor. Recontext (`recontext_<id>` / `recontext_stage_<n>`) and `VillageState` (`marker_<name>`) groups work untouched — they key on groups at zone enter.
- **`scripts/world/zone_root.gd` — `ZoneRoot`**: base for every zone scene. On `_ready` it now records `ZoneManager.current_scene_path = scene_file_path` (so saves reload *this* scene, including interiors), calls `enter_zone()`, defers `place_player_at_entry()`, and clamps the camera to `GroundBackdrop` (resets limits to `±LIMIT_OFF` when a scene has no backdrop, so a previous zone's limits never leak).
- **`scripts/autoload/zone_manager.gd` — `ZoneManager`**: the extended transition broker.
  - `go_to_scene(scene_path, spawn_id)` — transition to an explicit scene by **path** (interiors/floors that aren't in `ZONE_SCENES`); sets `arriving_spawn` + `current_scene_path`, deferred `change_scene_to_file`.
  - `request_transition(zone_id, spawn_id)` — legacy exterior path: resolves `zone_id` via `ZONE_SCENES`, then delegates to `go_to_scene`.
  - One-shot arrival state, consumed by `_resolve_destination`: `arriving_spawn` (explicit marker), `restore_position` (save-load Vector2), `current_scene_path` (live scene), `arriving_from` (legacy previous-zone id).

**`spawn_<id>` resolution (`place_player_at_entry` → `_resolve_destination`)**, in strict priority:
1. **`restore_position`** (save-load) — exact Vector2; beats everything, so reloading inside a basement keeps your spot.
2. **`spawn_<id>` marker** — nodes in group `spawn_<arriving_spawn>`; if the named marker is missing, falls back to `spawn_default` rather than nothing.
3. **Legacy `entry_from_<prev>` / `entry_default`** — preserved for the old exterior-zone slice flow.
4. **Plain boot / in-place reload** → returns `null`, player keeps its scene-default position (no teleport).
On placement, companions are snapped beside the player (offset `Vector2(-20, 14)`, rotated `TAU/3` per companion) so the family crosses together (playtest 2026-06-11).

**Save / load floor persistence (`scripts/autoload/save_manager.gd`)**: the save envelope stores `scene_path` (= `ZoneManager.current_scene_path`) and `player_pos` (exact `global_position`). On load it sets `current_zone_id` + `current_scene_path` **directly** (no `enter_zone`, so no `arriving_from` is recorded — the arriving `ZoneRoot`'s `enter_zone(same id)` is a no-op), sets `restore_position`, and `change_scene_to_file` to the **saved floor** (falling back to `ZONE_SCENES[zone_id]`, then `reload_current_scene`). Result: a basement save reloads in the basement, not the world.

## Authoring a new interior
1. New scene, root extends **`InteriorRoot`**; set a unique `zone_id`.
2. Add a **`GroundBackdrop`** (`Sprite2D`) — this *is* the camera-clamp source; without it the camera unclamps. One backdrop = one floor.
3. Add a **`spawn_default`** marker plus **named `spawn_<id>`** markers (e.g. `spawn_from_basement`, `spawn_from_cottage`) — one per inbound threshold, so each door deposits the player at the right spot.
4. Place **`DoorTransition`** nodes (`scripts/world/door_transition.gd`): set `target_scene` + the destination's `spawn_id`; choose `INTERACT` (doors/stairs you press) or `ENTER` (seamless mouths). Set `locked` + `locked_reason` for buildings you're flagging-not-authoring.
5. Optional: **`recontext_<id>`** groups (knowledge-gated decor/access, [[mechanics/zone-recontextualization]]) and **`recontext_stage_<n>`** (doom-keyed, [[mechanics/hollowing-clock]]); **`marker_<name>`** groups for `VillageState`-placed NPCs (e.g. `marker_marta`).
6. Set **`dread_baseline`**: `0.0` for a tended/safe home (dread decays — shelter); `> 0` for a cellar/cave/attic (raises the dread floor while inside).
7. Author darkness in-scene if wanted (ambient `PointLight2D` + `LightOccluder2D` walls) — `InteriorRoot` does not add lighting.

**Reference scene:** `scenes/zones/cottage_ground.tscn` (`zone_id = cottage_ground`, `dread_baseline = 0.0`): `GroundBackdrop`, `SpawnDefault` + `SpawnFromBasement`, an `ExitDoor` (`spawn_id = from_cottage`, "Step outside") and `StairsDown` (`spawn_id = from_above`, "Go down"), a `marker_marta` NPC spot, and a `recontext_monsters_are_children` sign.

## Design tiers
- **Tier A — full authored interior**: unique backdrop, NPCs, secrets, recontext, a dread/lighting plan. Reserve for story-load-bearing spaces (Rowan's home, the lottery hall, a cave reveal). **First Tier-A delivery: [[design/hollow-house-quest]]** — the investigation micro-quest that proves this system as *content*.
- **Tier B — shared template**: a stock hut/room reused with swapped decor — interiority without bespoke art.
- **Tier C — locked façade**: `DoorTransition.locked = true` + a diegetic `locked_reason`. The honest non-interior.
- **Rule: flag, don't author empty floors.** A locked door beats a bare room. **A few deep interiors beat many shallow ones** (same conservative-node-count logic as [[mechanics/zone-recontextualization]] — Void Stranger / Animal Well scale via dense, not numerous, space). Keep interior count small and each one meaningful.

## Art pipeline
- **Canon view: low top-down** (matches exteriors), palette-locked, flat/neutral lighting baked into the backdrop (runtime dread/darkness is layered on, not painted in).
- Floor/wall **tilesets via `create_topdown_tileset`** with an **explicit view** parameter so the tool returns true top-down tiles (not 3/4 or iso).
- **Stairs are the hard case** — they read as depth/perspective and fight a flat top-down floor. Approach: a **Grok concept pass** for the stair element, or **image-to-image depth** to get a believable descent without breaking the palette/view. Treat stairs as authored set-pieces, not tiled.
- **Pending**: real per-interior backdrops. The reference scene reuses a placeholder texture; `assets/sprites/interiors/cottage_ground_floor.png` + `cottage_basement_floor.png` are placeholders awaiting the real art pass.

## Edge cases
- **Camera clamp resets per floor**: every floor re-clamps to its own `GroundBackdrop`; a scene with no backdrop resets limits to `±LIMIT_OFF` so the previous floor's clamp never leaks across a transition.
- **Dread baseline clears on exit**: `InteriorRoot._exit_tree` emits `dread_zone_exited` so a cellar's dread floor doesn't follow you out or into the next floor.
- **Legacy `entry_from_<prev>` preserved**: the old exterior-zone entry-marker flow still resolves (priority 3) — interiors add `spawn_<id>` on top, they don't replace it.
- **Save on load is a no-op `enter_zone`**: load sets zone state directly so no spurious `arriving_from` is recorded, letting `restore_position` win and place the player exactly.
- **Missing named spawn** falls back to `spawn_default` (never a no-op drop at the scene-default origin).

## Related
[[mechanics/zone-recontextualization]] · [[mechanics/hollowing-clock]] · [[mechanics/vision-and-darkness]] · [[mechanics/day-night-hideout]] · [[mechanics/encounters-mercy]] · [[characters/companions]] · [[story/bible]]

> **Built**: the reference cottage is `cottage_ground.tscn` (exit→village + `StairsDown`→basement) and `cottage_basement.tscn` (raised `dread_baseline`, occluder walls + ambient light, `StairsUp`→ground). Stairs use `DoorTransition.target_scene_path` (string) to avoid a circular floor↔floor PackedScene load. Verified by a headless smoke: enter→basement→up and a basement save/load both land at the right spawns.
>
> **Pending**: real interior backdrop art + authored stair set-pieces (the slice uses graybox placeholders); additional interiors beyond the cottage; collision/dressing in the editor (the user's pass); the village-side `spawn_from_cottage` marker so the exit lands at the cottage door.
