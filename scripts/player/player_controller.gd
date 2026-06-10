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
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var attack_hitbox: Hitbox = $AttackHitbox

const ATTACK_WINDUP := 0.08
const ATTACK_WINDOW := 0.15
const ATTACK_REACH := 16.0
const HURT_SECONDS := 0.25
const HURT_DREAD := 4.0

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
	health.max_hp = PlayerData.max_hp
	health.restore_full()
	health.hp_changed.connect(_on_hp_changed)
	health.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)


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

var _attack_id := 0


func perform_attack() -> void:
	_attack_id += 1
	var my_attack := _attack_id
	movement_state = MovementState.ATTACKING
	attack_hitbox.position = _facing * ATTACK_REACH
	play_action_animation("attack")
	await get_tree().create_timer(ATTACK_WINDUP).timeout
	if my_attack == _attack_id and movement_state == MovementState.ATTACKING:
		attack_hitbox.activate(ATTACK_WINDOW)
	await get_tree().create_timer(ATTACK_WINDOW + 0.07).timeout
	# only the coroutine that still owns the attack may end it (Codex gate #3)
	if my_attack == _attack_id and movement_state == MovementState.ATTACKING:
		movement_state = MovementState.EXPLORING


func _on_hit_received(from_hitbox: Hitbox) -> void:
	attack_hitbox.deactivate()  # interrupted attacks must not leave a live hitbox
	set_movement_state(MovementState.HURT)
	velocity = from_hitbox.global_position.direction_to(global_position) * from_hitbox.knockback_force
	if animated_sprite:
		animated_sprite.modulate = Color(1.0, 0.5, 0.5)
	DreadManager.add_dread(HURT_DREAD, &"player_hurt")
	await get_tree().create_timer(HURT_SECONDS).timeout
	if animated_sprite:
		animated_sprite.modulate = Color.WHITE
	if movement_state == MovementState.HURT:
		movement_state = MovementState.EXPLORING


func _on_hp_changed(current: int, max_value: int) -> void:
	PlayerData.current_hp = current
	if GameEvents:
		GameEvents.player_damaged.emit(current, max_value)


func _on_died() -> void:
	# V1 stub per combat.md: "you wake at the edge of the woods" — reset with
	# consequences arriving in M2+ (bond drop, time advance).
	if GameEvents:
		GameEvents.player_died.emit()
	global_position = PlayerData.spawn_position
	velocity = Vector2.ZERO
	health.restore_full()
	DreadManager.add_dread(15.0, &"death")
	set_movement_state(MovementState.EXPLORING)

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
			attack_hitbox.deactivate()  # anim ended early — close the window with it
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
