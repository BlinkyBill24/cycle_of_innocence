extends Node
## JSON save/load (user://save_<slot>.json). PlayerData owns its own
## serialization; SaveManager adds world state (dread, zone) and the envelope.

signal game_saved(slot: int)
signal game_loaded(slot: int)

const SAVE_VERSION := 1


func save_path(slot: int = 0) -> String:
	return "user://save_%d.json" % slot


func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(save_path(slot))


func save_game(slot: int = 0) -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var data := {
		"version": SAVE_VERSION,
		"player": PlayerData.get_save_data(),
		"dread": DreadManager.dread,
		"zone_id": ZoneManager.current_zone_id,
		# scene path + exact position so an interior FLOOR reloads to itself,
		# at the spot you saved (accessible-interiors).
		"scene_path": ZoneManager.current_scene_path,
		"player_pos": [player.global_position.x, player.global_position.y] if player else null,
		"world": WorldState.get_save_data(),
		"hollowing": HollowingClock.get_save_data(),
		"village": VillageState.get_save_data(),
		"journal": Journal.get_save_data(),
	}
	var file := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open %s for writing" % save_path(slot))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit(slot)
	return true


func load_game(slot: int = 0, reload_scene: bool = true) -> bool:
	if not has_save(slot):
		return false
	var file := FileAccess.open(save_path(slot), FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("SaveManager: corrupt save in slot %d" % slot)
		return false
	var data := parsed as Dictionary
	# wipe any in-flight transition state (load may fire mid-transition, e.g.
	# from a menu) so restore_position is the only thing steering placement.
	ZoneManager.arriving_spawn = &""
	ZoneManager.arriving_from = &""
	ZoneManager.restore_position = null
	PlayerData.apply_save_data(data.get("player", {}))
	WorldState.apply_save_data(data.get("world", {}))
	HollowingClock.apply_save_data(data.get("hollowing", {}))
	VillageState.apply_save_data(data.get("village", {}))
	Journal.apply_save_data(data.get("journal", {}))
	DreadManager.reset()
	DreadManager.add_dread(float(data.get("dread", 0.0)), &"load")
	var zone_id := StringName(str(data.get("zone_id", PlayerData.last_zone_id)))
	# set zone state directly (no enter_zone, so no arriving_from is recorded) —
	# the arriving ZoneRoot's enter_zone(same id) is then a no-op, and
	# restore_position places the player at the exact saved spot.
	ZoneManager.current_zone_id = zone_id
	PlayerData.last_zone_id = zone_id
	var saved_path := str(data.get("scene_path", ""))
	if saved_path.is_empty():
		saved_path = ZoneManager.ZONE_SCENES.get(zone_id, "")
	ZoneManager.current_scene_path = saved_path
	var ppos: Variant = data.get("player_pos", null)
	if ppos is Array and (ppos as Array).size() == 2:
		ZoneManager.restore_position = Vector2(float(ppos[0]), float(ppos[1]))
	game_loaded.emit(slot)
	if reload_scene:
		# load the SAVED floor/zone (interior-aware) — not just whatever scene
		# happens to be live — so a basement save reloads in the basement.
		if not saved_path.is_empty() and ResourceLoader.exists(saved_path):
			get_tree().change_scene_to_file.call_deferred(saved_path)
		else:
			get_tree().reload_current_scene.call_deferred()
	return true


func delete_save(slot: int = 0) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path(slot)))
