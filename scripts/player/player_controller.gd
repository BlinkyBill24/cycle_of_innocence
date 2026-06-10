extends CharacterBody2D
class_name PlayerController

const AgeMorphT := preload("res://scripts/player/age_morph.gd")

## Extended from rpg-adventure prototype for Cycle of Innocence.
## Real-time action (Zelda/Mana), age stage visuals, morality, companion interaction hooks.

enum MovementState { EXPLORING, ATTACKING, HURT, CUTSCENE, DREAD_LOCK }
enum AgeStage { CHILD, TEEN, ADULT }

@export var move_speed: float = 110.0
@export var acceleration: float = 900.0
@export var friction: float = 1200.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var age_morph: AgeMorphT = $AgeMorph

var movement_state: MovementState = MovementState.EXPLORING
var age_stage: AgeStage = AgeStage.CHILD
var morality: float = 0.0
var _facing: Vector2 = Vector2.DOWN
var _action_anim_lock: bool = false

func _ready() -> void:
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
	_sync_from_player_data()
	PlayerData.age_advanced.connect(_on_player_data_age_advanced)
	PlayerData.morality_changed.connect(_on_player_data_morality_changed)


func _sync_from_player_data() -> void:
	age_stage = PlayerData.age_stage as AgeStage
	morality = PlayerData.morality


func _on_player_data_age_advanced(new_stage: int) -> void:
	apply_age_visuals(new_stage as AgeStage)


func _on_player_data_morality_changed(new_value: float, _delta: float) -> void:
	morality = new_value

func _physics_process(delta: float) -> void:
	if movement_state != MovementState.EXPLORING:
		_decelerate(delta)
		move_and_slide()
		if not _action_anim_lock:
			_update_locomotion_animation()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		_facing = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * move_speed, acceleration * delta)
	else:
		_decelerate(delta)

	move_and_slide()
	if not _action_anim_lock:
		_update_locomotion_animation()

	# Real-time attack (no pause menu)
	if Input.is_action_just_pressed("attack") and movement_state == MovementState.EXPLORING:
		perform_attack()

func _decelerate(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _update_locomotion_animation() -> void:
	if not animated_sprite:
		return
	var moving := velocity.length() > 8.0
	var anim_name := ("walk_" if moving else "idle_") + _facing_suffix()
	_play_if_changed(anim_name)

func _play_if_changed(anim_name: String) -> void:
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name) and animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)

func _facing_suffix() -> String:
	if absf(_facing.x) > absf(_facing.y):
		return "right" if _facing.x > 0.0 else "left"
	return "down" if _facing.y > 0.0 else "up"

func perform_attack() -> void:
	# TODO: spawn hitbox / Area2D in facing dir, play anim, damage nearby enemies or interact
	movement_state = MovementState.ATTACKING
	play_action_and_wait("attack")
	# After anim, return to EXPLORING in _on_animation_finished or timer
	await get_tree().create_timer(0.3).timeout
	if movement_state == MovementState.ATTACKING:
		movement_state = MovementState.EXPLORING

func play_action_animation(action: String) -> void:
	var anim_name := "%s_%s" % [action, _facing_suffix()]
	if not animated_sprite or not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	_action_anim_lock = true
	animated_sprite.play(anim_name)

func play_action_and_wait(action: String) -> void:
	var anim_name := "%s_%s" % [action, _facing_suffix()]
	if not animated_sprite or not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	_action_anim_lock = true
	animated_sprite.play(anim_name)
	await animated_sprite.animation_finished
	_action_anim_lock = false
	_update_locomotion_animation()

func _on_animation_finished() -> void:
	if _action_anim_lock and animated_sprite and not animated_sprite.animation.begins_with("walk_") and not animated_sprite.animation.begins_with("idle_"):
		_action_anim_lock = false
		_update_locomotion_animation()
		if movement_state == MovementState.ATTACKING:
			movement_state = MovementState.EXPLORING

func set_movement_state(new_state: MovementState) -> void:
	movement_state = new_state
	if new_state != MovementState.EXPLORING:
		velocity = Vector2.ZERO
		if not _action_anim_lock and animated_sprite:
			_update_locomotion_animation()

func get_facing() -> Vector2:
	return _facing

func apply_age_visuals(new_stage: AgeStage) -> void:
	age_stage = new_stage
	if age_morph:
		age_morph.apply_visual_state(
			PlayerData.age_stage,
			PlayerData.morality,
			PlayerData.companions
		)
