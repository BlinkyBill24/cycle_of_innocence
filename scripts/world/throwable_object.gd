class_name ThrowableObject
extends Node2D
## A loose object Rowan can lift and hurl (the pick-up-throw verb). Web-safe by
## design: the arc is a FAKED height — a parabola lerped onto the Visual's y while
## a Shadow stays on the ground — NOT RigidBody2D gravity. While airborne it
## carries a player-faction Hitbox, so striking a monster routes through the SAME
## Hurtbox/Faction path as the slingshot's ThrownProjectile (one damage system,
## per the goal — no second combat path).

enum State { RESTING, CARRIED, FLYING, LANDED }

@export var object_id: StringName = &"loose_rock"
@export var throw_damage: int = 1
@export var throw_range: float = 120.0   # px travelled over a throw
@export var throw_time: float = 0.5      # seconds in the air
@export var arc_height: float = 22.0     # peak fake-height in px
@export var breaks_on_land: bool = false ## shatters (frees) instead of resting

## Carried object hovers just above Rowan's head.
const CARRY_OFFSET := Vector2(0, -14)
const CARRY_LIFT := 10.0  # held-up height while carried

@onready var _visual: Node2D = $Visual
@onready var _shadow: Node2D = $Shadow
@onready var _hitbox: Hitbox = $Hitbox

var state: State = State.RESTING
var _carrier: Node2D
var _dir := Vector2.RIGHT
var _start := Vector2.ZERO
var _t := 0.0


func _ready() -> void:
	add_to_group("throwable")
	_hitbox.faction = &"player"        # the shared thrown-hit path: a player Hitbox
	_hitbox.damage = throw_damage
	_hitbox.set_shapes_disabled(true)  # inert until thrown
	_set_height(0.0)


## A resting/landed object can be lifted; one in flight or already carried can't.
func is_available() -> bool:
	return state == State.RESTING or state == State.LANDED


## Lift it (player interact). The carrier holds the ref; the object follows.
func pick_up(by: Node2D) -> void:
	if not is_available():
		return
	state = State.CARRIED
	_carrier = by
	_hitbox.set_shapes_disabled(true)
	_shadow.visible = false
	if GameEvents:
		GameEvents.throwable_picked_up.emit(object_id)


## Hurl it in `dir` from where it's carried. Arms the player-faction Hitbox for
## the whole flight so enemy Hurtboxes detect it.
func throw_in_dir(dir: Vector2) -> void:
	if state != State.CARRIED:
		return
	_dir = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
	_start = global_position
	_t = 0.0
	state = State.FLYING
	_carrier = null
	_shadow.visible = true
	_hitbox.set_shapes_disabled(false)
	if GameEvents:
		GameEvents.throwable_thrown.emit(object_id)


func _physics_process(delta: float) -> void:
	match state:
		State.CARRIED:
			if is_instance_valid(_carrier):
				global_position = _carrier.global_position + CARRY_OFFSET
				_set_height(CARRY_LIFT)
			else:
				_land()  # carrier vanished -> drop where it is
		State.FLYING:
			_t = minf(_t + delta / throw_time, 1.0)
			global_position = _start + _dir * throw_range * _t
			# parabola peaking at t=0.5, zero at both ends — the fake arc
			_set_height(arc_height * 4.0 * _t * (1.0 - _t))
			if _t >= 1.0:
				_land()


## Move only the Visual up by `h`; the Shadow stays on the ground (the fake height).
func _set_height(h: float) -> void:
	if _visual:
		_visual.position.y = -h


func _land() -> void:
	state = State.LANDED
	_set_height(0.0)
	_hitbox.set_shapes_disabled(true)
	if GameEvents:
		GameEvents.throwable_landed.emit(object_id)
	if breaks_on_land:
		Sfx.play(&"hit", -4.0)   # shatter (reuse the impact thud)
		queue_free()
	else:
		Sfx.play(&"hit", -12.0)  # a soft clatter; it rests and can be lifted again
