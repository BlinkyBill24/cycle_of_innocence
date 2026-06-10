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
	var data := {
		"version": SAVE_VERSION,
		"player": PlayerData.get_save_data(),
		"dread": DreadManager.dread,
		"zone_id": ZoneManager.current_zone_id,
	}
	var file := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open %s for writing" % save_path(slot))
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit(slot)
	return true


func load_game(slot: int = 0) -> bool:
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
	PlayerData.apply_save_data(data.get("player", {}))
	DreadManager.reset()
	DreadManager.add_dread(float(data.get("dread", 0.0)), &"load")
	ZoneManager.enter_zone(StringName(str(data.get("zone_id", PlayerData.last_zone_id))))
	game_loaded.emit(slot)
	return true


func delete_save(slot: int = 0) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path(slot)))
