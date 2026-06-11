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
const HURT_DREAD := 7.0
# Space both advances dialogue (ui_accept) and attacks — the balloon-closing
# press is still "just pressed" the frame control returns (playtest 2026-06-11).
const POST_CUTSCENE_INPUT_GRACE := 0.15

var movement_state: MovementState = MovementState.EXPLORING
var age_stage: AgeStage = AgeStage.CHILD
var morality: float = 0.0
var _facing: Vector2 = Vector2.DOWN
var _action_anim_lock: bool = false
var _footstep_timer: float = 0.0
var _input_grace: float = 0.0

const SOOTHE_RANGE := 80.0
const SOOTHE_RATE := 30.0  # recognition per second (≈3.3s to Still)
const SOOTHE_KEY_BONUS := 1.6  # the child's specific key (encounters-mercy.md)
const BRIAR_CALM_BONUS := 1.5  # Briar lying down non-threateningly nearby
const BRIAR_CALM_MIN_BOND := 25.0
const BRIAR_CALM_RANGE := 90.0
const DOMINATE_RATE_FACTOR := 1.4  # fear is faster than trust — by design
var _soothing := false
var _soothe_target: EnemyBase

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
	_input_grace = maxf(_input_grace - delta, 0.0)
	if movement_state != MovementState.EXPLORING:
		_decelerate(delta)
		move_and_slide()
		if not _action_anim_lock:
			_update_locomotion_animation()
		return

	if _soothing:
		_update_soothe(delta)
		_decelerate(delta)
		move_and_slide()
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
	_update_footsteps(delta)

	if _input_grace > 0.0:
		return

	# Real-time attack (no pause menu)
	if Input.is_action_just_pressed("attack") and movement_state == MovementState.EXPLORING:
		perform_attack()

	if Input.is_action_just_pressed("interact") and movement_state == MovementState.EXPLORING:
		_on_interact_pressed()

func _decelerate(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _update_footsteps(delta: float) -> void:
	if velocity.length() < 30.0:
		_footstep_timer = 0.12
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		Sfx.play(&"footstep", -10.0, 0.12)
		_footstep_timer = 0.34


const ASSIST_RANGE := 48.0

## Interact priority: soothe a nearby spareable monster, else companion dig.
func _on_interact_pressed() -> void:
	var monster := _nearest_spareable_monster()
	if monster:
		_start_soothe(monster)
		return
	var hideout := get_tree().get_first_node_in_group("hideout") as Hideout
	if hideout and hideout.try_interact(self):
		return
	_try_companion_assist()


func _nearest_spareable_monster() -> EnemyBase:
	var nearest: EnemyBase = null
	var best := SOOTHE_RANGE
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as EnemyBase
		if enemy and enemy.spareable and not enemy.stilled and not enemy.dominated:
			var dist := global_position.distance_to(enemy.global_position)
			if dist < best:
				best = dist
				nearest = enemy
	return nearest


func _start_soothe(target: EnemyBase) -> void:
	# Hold-to-soothe (encounters-mercy.md): defenseless channel — hurtbox
	# stays live, movement stops, the lullaby is the only shield.
	_soothing = true
	_soothe_target = target
	AdaptiveAudio.duck(8.0)  # let the lullaby carry
	Sfx.play(&"lullaby", -6.0, 0.0)
	if animated_sprite and animated_sprite.sprite_frames \
			and animated_sprite.sprite_frames.has_animation("crouch"):
		_action_anim_lock = true
		animated_sprite.play("crouch")


func _update_soothe(delta: float) -> void:
	if not Input.is_action_pressed("interact") \
			or _soothe_target == null or not is_instance_valid(_soothe_target) \
			or _soothe_target.stilled or _soothe_target.dominated \
			or global_position.distance_to(_soothe_target.global_position) > SOOTHE_RANGE * 1.4:
		_stop_soothe()
		return
	AdaptiveAudio.duck(18.0)  # held every frame: the lullaby owns the channel
	# Vessel-tier Rowan no longer asks — the same hold becomes Domination:
	# unaffected by dread, needs no key. Fear is the easy road.
	if PlayerData.get_morality_tier() == PlayerData.MoralityTier.VESSEL:
		if _soothe_target.add_domination(SOOTHE_RATE * DOMINATE_RATE_FACTOR * delta):
			_stop_soothe()
		return
	var has_key := PlayerData.has_story_flag(_soothe_target.soothe_key_flag)
	var calm_anchor := _briar_calm_companion(_soothe_target)
	if calm_anchor:
		calm_anchor.show_calm()  # he lies down — the child trusts the dog first
	var rate := soothe_rate(SOOTHE_RATE, DreadManager.dread, has_key, calm_anchor != null)
	if _soothe_target.add_recognition(rate * delta, has_key):
		_stop_soothe()


## Pure rate rule (encounters-mercy.md), unit-tested: the specific key and
## Briar's calm presence stack; dread > 80 halves everything.
static func soothe_rate(base: float, dread: float, has_key: bool, briar_calm: bool) -> float:
	var rate := base
	if has_key:
		rate *= SOOTHE_KEY_BONUS
	if briar_calm:
		rate *= BRIAR_CALM_BONUS
	if dread > 80.0:
		rate *= 0.5  # mercy is hardest when terrified — by design
	return rate


func _briar_calm_companion(target: EnemyBase) -> CompanionBase:
	var companion := get_tree().get_first_node_in_group("companion") as CompanionBase
	if companion != null and not companion.is_afraid() \
			and companion.get_bond() >= BRIAR_CALM_MIN_BOND \
			and companion.global_position.distance_to(target.global_position) <= BRIAR_CALM_RANGE:
		return companion
	return null


func _stop_soothe() -> void:
	Sfx.stop(&"lullaby")
	_soothing = false
	_soothe_target = null
	_action_anim_lock = false
	_update_locomotion_animation()


func _try_companion_assist() -> void:
	var companion := get_tree().get_first_node_in_group("companion") as CompanionBase
	if companion == null:
		return
	var nearest: DiggableSpot = null
	var nearest_revealed: DiggableSpot = null
	var best := ASSIST_RANGE
	var best_revealed := ASSIST_RANGE
	for node in get_tree().get_nodes_in_group("diggable"):
		var spot := node as DiggableSpot
		if spot == null:
			continue
		var dist := global_position.distance_to(spot.global_position)
		if not spot.revealed and dist < best:
			best = dist
			nearest = spot
		elif spot.revealed and dist < best_revealed:
			best_revealed = dist
			nearest_revealed = spot
	if nearest:
		companion.command_dig(nearest)
	elif nearest_revealed:
		# standing on dug-up earth: answer the press so silence never reads as
		# a bug — there is just nothing left buried here (playtest 2026-06-11)
		companion.signal_nothing_to_dig()

## PixelLab characters have true 4-direction rows (incl. west) — no mirroring.
## Returns [animation_name, flip_h]; pure for testability.
static func directional_anim(action: String, facing: Vector2) -> Array:
	var suffix := ""
	if absf(facing.x) > absf(facing.y):
		suffix = "right" if facing.x > 0.0 else "left"
	else:
		suffix = "down" if facing.y > 0.0 else "up"
	return ["%s_%s" % [action, suffix], false]


func _update_locomotion_animation() -> void:
	if not animated_sprite:
		return
	var moving := velocity.length() > 8.0
	var anim: Array = directional_anim("walk" if moving else "idle", _facing)
	animated_sprite.flip_h = anim[1]
	_play_if_changed(anim[0])

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
	Sfx.play(&"swing", -6.0)
	await get_tree().create_timer(ATTACK_WINDUP).timeout
	if my_attack == _attack_id and movement_state == MovementState.ATTACKING:
		attack_hitbox.activate(ATTACK_WINDOW)
	await get_tree().create_timer(ATTACK_WINDOW + 0.07).timeout
	# only the coroutine that still owns the attack may end it (Codex gate #3)
	if my_attack == _attack_id and movement_state == MovementState.ATTACKING:
		movement_state = MovementState.EXPLORING


func _on_hit_received(from_hitbox: Hitbox) -> void:
	attack_hitbox.deactivate()  # interrupted attacks must not leave a live hitbox
	if _soothing:
		_stop_soothe()  # the channel breaks when the world bites back
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
	var anim: Array = directional_anim(action, _facing)
	if not animated_sprite or not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim[0]):
		return
	_action_anim_lock = true
	animated_sprite.flip_h = anim[1]
	animated_sprite.play(anim[0])

func play_action_and_wait(action: String) -> void:
	var anim: Array = directional_anim(action, _facing)
	if not animated_sprite or not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim[0]):
		return
	_action_anim_lock = true
	animated_sprite.flip_h = anim[1]
	animated_sprite.play(anim[0])
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
	var previous := movement_state
	movement_state = new_state
	if new_state == MovementState.EXPLORING \
			and previous in [MovementState.CUTSCENE, MovementState.DREAD_LOCK]:
		_input_grace = POST_CUTSCENE_INPUT_GRACE
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
