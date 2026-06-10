class_name ZoneTransition
extends Area2D
## Edge trigger toward another zone. With only one zone built, it records the
## request via ZoneManager (listeners/debug react); scene switching lands M2+.

@export var target_zone_id: StringName = &"village_edge"


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player body layer
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		ZoneManager.request_transition(target_zone_id)
