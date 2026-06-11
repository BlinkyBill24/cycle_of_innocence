class_name ZoneRoot
extends Node2D
## Base for zone scenes: registers itself with ZoneManager on ready and
## places the player at the entry point matching the previous zone.

@export var zone_id: StringName = &"unnamed_zone"


func _ready() -> void:
	ZoneManager.enter_zone(zone_id)
	ZoneManager.place_player_at_entry.call_deferred(self)
