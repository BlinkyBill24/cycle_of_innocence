class_name ThrownProjectile
extends Hitbox
## A simple thrown shot (slingshot stone). It IS a player-faction Hitbox (layer 32)
## so enemy Hurtboxes detect it on contact; it flies straight, damages each enemy
## it passes once (Hurtbox.area_entered fires on enter), and frees on hit or after
## `lifetime` (its range). Web-safe: plain Area2D motion, no threads.

@export var speed: float = 220.0
@export var lifetime: float = 1.1

var _dir: Vector2 = Vector2.RIGHT


## Aim + arm the shot before adding it to the tree.
func setup(direction: Vector2, dmg: int = 1) -> void:
	if direction != Vector2.ZERO:
		_dir = direction.normalized()
	damage = dmg


func _ready() -> void:
	super._ready()  # monitoring=false, monitorable=true, shapes disabled
	faction = &"player"
	add_to_group("thrown")     # shared thrown-hit marker (NPC reactions key off this)
	monitoring = true          # we also watch so we can stop on first body hit
	collision_mask = 1         # world / enemy body layer
	set_shapes_disabled(false)  # live the whole flight (Hurtboxes can detect us)
	rotation = _dir.angle()
	body_entered.connect(func(_b: Node2D) -> void: queue_free())  # thunk on a wall/enemy
	get_tree().create_timer(lifetime).timeout.connect(_expire)


func _physics_process(delta: float) -> void:
	global_position += _dir * speed * delta


func _expire() -> void:
	if is_instance_valid(self):
		queue_free()
