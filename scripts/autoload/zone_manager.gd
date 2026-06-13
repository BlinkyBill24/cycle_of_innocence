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
## Path of the live scene — recorded by ZoneRoot on enter (incl. the booted
## scene) and by every transition. Saved so an interior FLOOR reloads to
## itself, not the world (accessible-interiors).
var current_scene_path: String = ""
## Set during a transition; the arriving zone's player spawns at the
## matching entry marker. Cleared after consumption.
var arriving_from: StringName = &""
## Explicit spawn marker the arriving scene should use (group "spawn_<id>").
## Takes priority over the legacy entry_from_<prev>. Cleared after consumption.
var arriving_spawn: StringName = &""
## Exact position a save-load wants the player restored to (Vector2 or null).
## Beats marker resolution so reloading inside a basement keeps your spot.
var restore_position: Variant = null


func enter_zone(zone_id: StringName) -> void:
	if zone_id.is_empty() or zone_id == current_zone_id:
		return
	var previous := current_zone_id
	current_zone_id = zone_id
	PlayerData.last_zone_id = zone_id
	if not previous.is_empty():
		arriving_from = previous
	zone_changed.emit(zone_id)


## Legacy exterior-zone transition: zone_id resolved via ZONE_SCENES.
## spawn_id optionally targets a "spawn_<id>" marker in the destination.
func request_transition(target_zone_id: StringName, spawn_id: StringName = &"") -> void:
	transition_requested.emit(target_zone_id)
	var path: String = ZONE_SCENES.get(target_zone_id, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return  # unauthored zone: record intent only (old slice behavior)
	go_to_scene(path, spawn_id)


## Transition to an explicit scene by path (interiors/floors not in
## ZONE_SCENES), placing the player at "spawn_<spawn_id>" on arrival. The
## destination's ZoneRoot sets the new zone_id via enter_zone() on _ready.
func go_to_scene(scene_path: String, spawn_id: StringName = &"") -> void:
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_warning("ZoneManager.go_to_scene: missing scene '%s'" % scene_path)
		return
	arriving_spawn = spawn_id
	current_scene_path = scene_path
	get_tree().change_scene_to_file.call_deferred(scene_path)


## Called by ZoneRoot after the new scene is up: position the player. Priority:
## (1) a save-load restore_position, (2) an explicit spawn_<id> marker,
## (3) the legacy entry_from_<prev>/entry_default. No-op on a plain boot
## (no transition + no restore) so the player keeps its scene-default spot.
func place_player_at_entry(zone: Node) -> void:
	var player := zone.get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var dest: Variant = _resolve_destination(zone)
	if dest == null:
		return
	player.global_position = dest
	PlayerData.spawn_position = player.global_position
	# the family crosses together — companions must not sprint over from
	# their scene-default spot (playtest 2026-06-11)
	var offset := Vector2(-20, 14)
	for node in zone.get_tree().get_nodes_in_group("companion"):
		var companion := node as Node2D
		if companion:
			companion.global_position = player.global_position + offset
			offset = offset.rotated(TAU / 3.0)


## Where to put the player on arrival, or null to leave it. Consumes the
## one-shot restore_position / arriving_spawn / arriving_from state.
func _resolve_destination(zone: Node) -> Variant:
	if restore_position != null:
		var pos: Vector2 = restore_position
		restore_position = null
		arriving_spawn = &""
		arriving_from = &""
		return pos
	if arriving_spawn != &"":
		var sp := zone.get_tree().get_nodes_in_group("spawn_" + String(arriving_spawn))
		arriving_spawn = &""
		arriving_from = &""
		if not sp.is_empty():
			return (sp[0] as Node2D).global_position
		# named spawn missing — fall back to spawn_default rather than nothing
		var d := zone.get_tree().get_nodes_in_group("spawn_default")
		return (d[0] as Node2D).global_position if not d.is_empty() else null
	if not arriving_from.is_empty():
		var from := arriving_from
		arriving_from = &""
		var entries := zone.get_tree().get_nodes_in_group("entry_from_" + String(from))
		if entries.is_empty():
			entries = zone.get_tree().get_nodes_in_group("entry_default")
		return (entries[0] as Node2D).global_position if not entries.is_empty() else null
	return null  # plain boot / in-place reload — don't move the player
