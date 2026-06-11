extends Node
## Tracks the current zone and brokers REAL transitions (M2: second zone).
## Zones self-register on ready (ZoneRoot); transitions switch scenes and
## place the player at the entry point matching where they came from
## (group "entry_from_<previous_zone_id>", else "entry_default").

signal zone_changed(zone_id: StringName)
signal transition_requested(target_zone_id: StringName)

## zone_id -> scene path. Authored, grows with the world.
const ZONE_SCENES := {
	&"playground_fringes": "res://scenes/zones/playground_fringes.tscn",
	&"village_edge": "res://scenes/zones/village_green.tscn",
}

var current_zone_id: StringName = &""
## Set during a transition; the arriving zone's player spawns at the
## matching entry marker. Cleared after consumption.
var arriving_from: StringName = &""


func enter_zone(zone_id: StringName) -> void:
	if zone_id.is_empty() or zone_id == current_zone_id:
		return
	var previous := current_zone_id
	current_zone_id = zone_id
	PlayerData.last_zone_id = zone_id
	if not previous.is_empty():
		arriving_from = previous
	zone_changed.emit(zone_id)


func request_transition(target_zone_id: StringName) -> void:
	transition_requested.emit(target_zone_id)
	var path: String = ZONE_SCENES.get(target_zone_id, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return  # unauthored zone: record intent only (old slice behavior)
	get_tree().change_scene_to_file.call_deferred(path)


## Called by ZoneRoot after the new scene is up: position the player at the
## entry point matching the zone they came from.
func place_player_at_entry(zone: Node) -> void:
	if arriving_from.is_empty():
		return
	var from := arriving_from
	arriving_from = &""
	var player := zone.get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var entries := zone.get_tree().get_nodes_in_group("entry_from_" + String(from))
	if entries.is_empty():
		entries = zone.get_tree().get_nodes_in_group("entry_default")
	if entries.is_empty():
		return
	player.global_position = (entries[0] as Node2D).global_position
	PlayerData.spawn_position = player.global_position
	# the family crosses together — companions must not sprint over from
	# their scene-default spot (playtest 2026-06-11)
	var offset := Vector2(-20, 14)
	for node in zone.get_tree().get_nodes_in_group("companion"):
		var companion := node as Node2D
		if companion:
			companion.global_position = player.global_position + offset
			offset = offset.rotated(TAU / 3.0)
