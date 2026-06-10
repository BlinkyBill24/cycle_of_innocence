class_name ZoneRoot
extends Node2D
## Base for zone scenes: registers itself with ZoneManager on ready.

@export var zone_id: StringName = &"unnamed_zone"


func _ready() -> void:
	ZoneManager.enter_zone(zone_id)
