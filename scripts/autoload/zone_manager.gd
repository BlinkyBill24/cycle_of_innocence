extends Node
## Tracks the current zone and brokers transitions. Zones self-register on
## ready (ZoneRoot); dread areas inside zones register their levels with
## DreadManager. Actual scene switching arrives with the second zone (M2+).

signal zone_changed(zone_id: StringName)
signal transition_requested(target_zone_id: StringName)

var current_zone_id: StringName = &""


func enter_zone(zone_id: StringName) -> void:
	if zone_id.is_empty() or zone_id == current_zone_id:
		return
	current_zone_id = zone_id
	PlayerData.last_zone_id = zone_id
	zone_changed.emit(zone_id)


func request_transition(target_zone_id: StringName) -> void:
	# Slice stub: one zone exists; record intent and let listeners react.
	transition_requested.emit(target_zone_id)
