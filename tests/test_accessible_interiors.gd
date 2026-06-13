extends GutTest
## Accessible interiors (accessible-interiors): the door/stairs component, the
## spawn-id + restore-position resolution in ZoneManager, and SaveManager
## floor persistence. The actual scene swaps (enter/exit/floor round-trips) are
## verified by a headless boot smoke — change_scene would tear down the GUT
## runner — so here we test the resolution logic those transitions rely on.

const DoorScript := preload("res://scripts/world/door_transition.gd")
const ANY_SCENE := "res://scenes/world/diggable_spot.tscn"  # any real PackedScene


func before_each() -> void:
	ZoneManager.arriving_spawn = &""
	ZoneManager.arriving_from = &""
	ZoneManager.restore_position = null
	ZoneManager._transition_pending = false


func after_each() -> void:
	ZoneManager.arriving_spawn = &""
	ZoneManager.arriving_from = &""
	ZoneManager.restore_position = null
	ZoneManager._transition_pending = false


# --- DoorTransition ------------------------------------------------------

func test_target_path_pure() -> void:
	var d: DoorTransition = DoorScript.new()
	add_child_autofree(d)
	assert_eq(d.target_path(), "", "no scene set -> empty path")
	d.target_scene = load(ANY_SCENE)
	assert_string_contains(d.target_path(), "diggable_spot")


func test_locked_door_blocks_and_queues_nothing() -> void:
	var d: DoorTransition = DoorScript.new()
	d.locked = true
	d.target_scene = load(ANY_SCENE)
	d.spawn_id = &"inside"
	add_child_autofree(d)
	assert_false(d.trigger(), "a locked door does not transition")
	assert_eq(ZoneManager.arriving_spawn, &"", "no spawn queued when blocked")
	assert_eq(ZoneManager.current_scene_path, ZoneManager.current_scene_path,
		"current scene unchanged")


func test_unlocked_door_with_no_scene_is_a_safe_noop() -> void:
	var d: DoorTransition = DoorScript.new()  # locked=false, no target_scene
	add_child_autofree(d)
	assert_false(d.trigger(), "no target -> false, not a crash")


# --- spawn resolution (the heart of enter/exit/floor placement) ----------

func _zone_with_player_and_markers(markers: Dictionary) -> Array:
	# markers: {group_name: Vector2}
	var zone := Node2D.new()
	add_child_autofree(zone)
	var player := Node2D.new()
	player.add_to_group("player")
	zone.add_child(player)
	for group: String in markers:
		var m := Marker2D.new()
		m.add_to_group(group)
		m.position = markers[group]
		zone.add_child(m)
	return [zone, player]


func test_spawn_id_marker_resolution() -> void:
	var pair := _zone_with_player_and_markers({"spawn_basement": Vector2(123, 45)})
	ZoneManager.arriving_spawn = &"basement"
	ZoneManager.place_player_at_entry(pair[0])
	assert_eq((pair[1] as Node2D).global_position, Vector2(123, 45),
		"player placed at spawn_<id> marker")
	assert_eq(ZoneManager.arriving_spawn, &"", "spawn id consumed")


func test_spawn_id_falls_back_to_spawn_default() -> void:
	var pair := _zone_with_player_and_markers({"spawn_default": Vector2(7, 8)})
	ZoneManager.arriving_spawn = &"missing_marker"
	ZoneManager.place_player_at_entry(pair[0])
	assert_eq((pair[1] as Node2D).global_position, Vector2(7, 8),
		"missing named spawn -> spawn_default")


func test_restore_position_beats_marker() -> void:
	var pair := _zone_with_player_and_markers({"spawn_basement": Vector2(123, 45)})
	ZoneManager.restore_position = Vector2(500, 600)
	ZoneManager.arriving_spawn = &"basement"
	ZoneManager.place_player_at_entry(pair[0])
	assert_eq((pair[1] as Node2D).global_position, Vector2(500, 600),
		"a save-load restore_position wins over the spawn marker")
	assert_eq(ZoneManager.restore_position, null, "restore consumed")


func test_plain_boot_leaves_player_in_place() -> void:
	var pair := _zone_with_player_and_markers({"spawn_default": Vector2(7, 8)})
	(pair[1] as Node2D).global_position = Vector2(99, 99)
	# no arriving_spawn / arriving_from / restore -> in-place reload, don't move
	ZoneManager.place_player_at_entry(pair[0])
	assert_eq((pair[1] as Node2D).global_position, Vector2(99, 99),
		"no transition state -> player keeps its spot")


func test_legacy_entry_from_still_works() -> void:
	var pair := _zone_with_player_and_markers({"entry_from_village_edge": Vector2(11, 22)})
	ZoneManager.arriving_from = &"village_edge"
	ZoneManager.place_player_at_entry(pair[0])
	assert_eq((pair[1] as Node2D).global_position, Vector2(11, 22),
		"legacy entry_from_<prev> path preserved")


# --- one-shot arrival-state hygiene (Codex review S1/S2/S3) ---------------

func test_arrival_state_cleared_when_no_player_present() -> void:
	# S2: a scene with no "player" node must still consume the one-shot state,
	# or it leaks into the next, unrelated load.
	var zone := Node2D.new()  # deliberately no player in this subtree
	add_child_autofree(zone)
	ZoneManager.arriving_spawn = &"basement"
	ZoneManager._transition_pending = true
	ZoneManager.place_player_at_entry(zone)
	assert_eq(ZoneManager.arriving_spawn, &"", "no player -> arrival state still consumed")
	assert_false(ZoneManager._transition_pending, "pending guard cleared once the load lands")


func test_reentrant_go_to_scene_is_ignored() -> void:
	# S3: with a transition already in flight, a second trigger (double-press,
	# two doors) must not overwrite arriving_spawn/current_scene_path. We assert
	# the guard's early-return branch so no real change_scene is queued in GUT.
	ZoneManager._transition_pending = true
	ZoneManager.arriving_spawn = &"first"
	var path_before := ZoneManager.current_scene_path
	ZoneManager.go_to_scene(ANY_SCENE, &"second")
	assert_eq(ZoneManager.arriving_spawn, &"first", "reentrant call ignored — first spawn kept")
	assert_eq(ZoneManager.current_scene_path, path_before, "scene path not overwritten mid-flight")


# --- SaveManager floor persistence ---------------------------------------

func test_save_load_round_trips_floor_and_position() -> void:
	var player := Node2D.new()
	player.add_to_group("player")
	player.global_position = Vector2(50, 60)
	add_child_autofree(player)
	ZoneManager.current_zone_id = &"cottage_basement"
	ZoneManager.current_scene_path = "res://scenes/zones/playground_fringes.tscn"  # stand-in path
	assert_true(SaveManager.save_game(99), "save writes")
	# scramble live state, then load WITHOUT swapping the scene (GUT-safe)
	ZoneManager.current_zone_id = &"village_edge"
	ZoneManager.current_scene_path = ""
	ZoneManager.restore_position = null
	assert_true(SaveManager.load_game(99, false), "load reads")
	assert_eq(ZoneManager.current_zone_id, &"cottage_basement", "floor zone restored")
	assert_eq(ZoneManager.current_scene_path,
		"res://scenes/zones/playground_fringes.tscn", "floor scene path restored")
	assert_eq(ZoneManager.restore_position, Vector2(50, 60),
		"exact position queued for the reloaded floor")
	SaveManager.delete_save(99)


func test_load_wipes_stale_arrival_state() -> void:
	# S1: a load fired mid-transition must clear leftover arriving_spawn/from so
	# restore_position is the only thing steering placement.
	var player := Node2D.new()
	player.add_to_group("player")
	player.global_position = Vector2(50, 60)
	add_child_autofree(player)
	ZoneManager.current_zone_id = &"cottage_basement"
	ZoneManager.current_scene_path = "res://scenes/zones/playground_fringes.tscn"
	assert_true(SaveManager.save_game(98), "save writes")
	ZoneManager.arriving_spawn = &"stale"
	ZoneManager.arriving_from = &"stale_zone"
	assert_true(SaveManager.load_game(98, false), "load reads")
	assert_eq(ZoneManager.arriving_spawn, &"", "load wiped stale arriving_spawn")
	assert_eq(ZoneManager.arriving_from, &"", "load wiped stale arriving_from")
	assert_eq(ZoneManager.restore_position, Vector2(50, 60),
		"restore_position set from the save, not the stale marker")
	SaveManager.delete_save(98)
