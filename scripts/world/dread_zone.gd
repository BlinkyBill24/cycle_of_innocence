class_name DreadZone
extends Area2D
## Area that raises the dread baseline while the player is inside.
## Registers its level with DreadManager and emits the global zone signals.

@export var dread_zone_id: StringName = &"dread_area"
@export var dread_level: float = 40.0


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player body layer
	DreadManager.register_zone_level(dread_zone_id, dread_level)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GameEvents:
		GameEvents.dread_zone_entered.emit(dread_zone_id)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and GameEvents:
		GameEvents.dread_zone_exited.emit(dread_zone_id)
