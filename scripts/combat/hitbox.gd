class_name Hitbox
extends Area2D
## Damage-dealing area. Inactive (shape disabled) by default; activate() opens
## a timed damage window. Hurtboxes of a DIFFERENT faction react to it.

@export var damage: int = 1
@export var faction: StringName = &"player"
@export var knockback_force: float = 160.0

var _activation_id := 0


func _ready() -> void:
	monitoring = false
	monitorable = true
	set_shapes_disabled(true)


func activate(duration: float) -> void:
	_activation_id += 1
	var my_id := _activation_id
	set_shapes_disabled(false)
	await get_tree().create_timer(duration).timeout
	# a newer activate()/deactivate() owns the shapes now — don't clobber it
	if my_id == _activation_id:
		set_shapes_disabled(true)


func deactivate() -> void:
	_activation_id += 1
	set_shapes_disabled(true)


func set_shapes_disabled(disabled: bool) -> void:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", disabled)
