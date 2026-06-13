class_name SurfaceZone
extends Area2D
## Marks a patch of ground as a footstep surface (gravel/path/wood/…), so the
## player's footsteps switch sound by where they're standing. Default ground
## is grass; drop these over paths, the ritual sand, etc.
##
## ROUGH by design — placement is an editor pass: add SurfaceZone nodes with a
## CollisionShape2D covering the patch, set `surface`. Overlapping zones: the
## last one the player entered wins (good enough; refine shapes in-editor).

@export var surface: StringName = &"gravel"

var _player_inside := false


func _ready() -> void:
	add_to_group("surface_zone")
	monitoring = true
	collision_mask = 2  # player body layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func has_player() -> bool:
	return _player_inside
