class_name EnemyBase
extends CharacterBody2D
## Base enemy: LimboAI HSM (patrol / chase / attack / hurt) driven by player
## proximity + line of sight. Carries the mercy stubs (Recognition/Stilled)
## that docs/mechanics/encounters-mercy.md fills in at M3.

@export var enemy_kind: StringName = &"twisted_child"
@export var move_speed: float = 35.0
@export var chase_speed: float = 65.0
@export var lunge_speed: float = 170.0
@export var detection_radius: float = 110.0
@export var lose_radius: float = 190.0
@export var attack_range: float = 26.0
@export var attack_cooldown: float = 1.4
@export var wander_radius: float = 50.0
@export var hurt_seconds: float = 0.25

## Mercy system (encounters-mercy.md): Recognition fills via soothing;
## at threshold the monster becomes Stilled (persisted via story flag).
@export var spareable: bool = true
@export var stable_id: StringName = &"twisted_child_01"  # unique per placed enemy
const RECOGNITION_MAX := 100.0
const SOOTHE_SLOW_FACTOR := 0.45
var recognition: float = 0.0
var stilled: bool = false
var _soothe_hold: float = 0.0  # >0 while the lullaby is actively reaching it

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var lunge_hitbox: Hitbox = $LungeHitbox
@onready var los_ray: RayCast2D = $LineOfSight

var hsm: LimboHSM
var _spawn: Vector2
var _wander_target: Vector2
var _wander_wait: float = 0.0
var _cooldown: float = 0.0
var _hurt_timer: float = 0.0
var _lunge_dir: Vector2 = Vector2.ZERO
var _facing: Vector2 = Vector2.DOWN

var _state_patrol: LimboState
var _state_chase: LimboState
var _state_attack: LimboState
var _state_hurt: LimboState
var _state_stilled: LimboState


func _ready() -> void:
	add_to_group("enemy")
	_spawn = global_position
	_wander_target = _spawn
	health.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)
	_init_hsm()
	if PlayerData.has_story_flag(_stilled_flag()):
		stilled = true
		recognition = RECOGNITION_MAX
		hsm.dispatch(&"stilled")


func _init_hsm() -> void:
	hsm = LimboHSM.new()
	add_child(hsm)

	_state_patrol = LimboState.new().named("Patrol") \
		.call_on_enter(_patrol_enter).call_on_update(_patrol_update)
	_state_chase = LimboState.new().named("Chase").call_on_update(_chase_update)
	_state_attack = LimboState.new().named("Attack") \
		.call_on_enter(_attack_enter).call_on_update(_attack_update)
	_state_hurt = LimboState.new().named("Hurt") \
		.call_on_enter(_hurt_enter).call_on_update(_hurt_update)
	_state_stilled = LimboState.new().named("Stilled").call_on_enter(_stilled_enter)

	for state: LimboState in [_state_patrol, _state_chase, _state_attack, _state_hurt, _state_stilled]:
		hsm.add_child(state)

	hsm.add_transition(_state_patrol, _state_chase, &"spotted")
	hsm.add_transition(_state_chase, _state_patrol, &"lost")
	hsm.add_transition(_state_chase, _state_attack, &"in_range")
	hsm.add_transition(_state_attack, _state_chase, &"attack_done")
	hsm.add_transition(hsm.ANYSTATE, _state_hurt, &"hit")
	hsm.add_transition(_state_hurt, _state_chase, &"recovered")
	hsm.add_transition(hsm.ANYSTATE, _state_stilled, &"stilled")

	hsm.initial_state = _state_patrol
	hsm.initialize(self)
	hsm.set_active(true)


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	_soothe_hold = maxf(_soothe_hold - delta, 0.0)
	# Stilled monsters don't run physics: a zero-velocity CharacterBody2D still
	# depenetrates from overlaps, so walking into one would drag it along
	# (playtest 2026-06-10).
	if not stilled:
		move_and_slide()
	_update_animation()
	_update_recognition_tint()


func _update_recognition_tint() -> void:
	# visible soothe feedback: the creature pales toward calm as Recognition grows
	if stilled:
		sprite.modulate = Color(0.85, 0.95, 1.1)
		return
	sprite.modulate = Color.WHITE.lerp(Color(0.82, 0.92, 1.08), (recognition / RECOGNITION_MAX) * 0.8)


# --- perception helpers (pure-ish; unit-tested) ---

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func distance_to_player() -> float:
	var player := get_player()
	return global_position.distance_to(player.global_position) if player else INF


func can_see_player() -> bool:
	var player := get_player()
	if player == null or stilled:
		return false
	if distance_to_player() > detection_radius:
		return false
	los_ray.target_position = to_local(player.global_position)
	los_ray.force_raycast_update()
	return not los_ray.is_colliding()


# --- states ---

func _patrol_enter() -> void:
	_wander_wait = randf_range(0.4, 1.4)


func _patrol_update(delta: float) -> void:
	if can_see_player():
		hsm.dispatch(&"spotted")
		return
	if global_position.distance_to(_wander_target) < 4.0:
		_wander_wait -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
		if _wander_wait <= 0.0:
			_wander_target = _spawn + Vector2(
				randf_range(-wander_radius, wander_radius),
				randf_range(-wander_radius, wander_radius))
			_wander_wait = randf_range(0.4, 1.4)
		return
	velocity = global_position.direction_to(_wander_target) * move_speed


func _chase_update(_delta: float) -> void:
	var player := get_player()
	if player == null or stilled or distance_to_player() > lose_radius:
		hsm.dispatch(&"lost")
		return
	var dist := distance_to_player()
	if dist <= attack_range and _cooldown <= 0.0 and _soothe_hold <= 0.0:
		hsm.dispatch(&"in_range")
		return
	if dist <= attack_range * 0.85:
		# standoff: hover just out of reach instead of pressing into the
		# player's body (depenetration glued it to them — playtest)
		velocity = velocity.move_toward(Vector2.ZERO, 500.0 * get_physics_process_delta_time())
		return
	# the lullaby reaches it: hesitates and slows instead of lunging
	var speed := chase_speed * (SOOTHE_SLOW_FACTOR if _soothe_hold > 0.0 else 1.0)
	velocity = global_position.direction_to(player.global_position) * speed


func _attack_enter() -> void:
	var player := get_player()
	_lunge_dir = global_position.direction_to(player.global_position) if player else _facing
	_cooldown = attack_cooldown
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("lunge"):
		sprite.play("lunge")
	lunge_hitbox.position = _lunge_dir * 10.0
	lunge_hitbox.activate(0.25)
	_hurt_timer = 0.35  # reused as lunge duration


func _attack_update(delta: float) -> void:
	_hurt_timer -= delta
	velocity = _lunge_dir * lunge_speed * maxf(_hurt_timer / 0.35, 0.0)
	if _hurt_timer <= 0.0:
		hsm.dispatch(&"attack_done")


func _hurt_enter() -> void:
	_hurt_timer = hurt_seconds
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("hurt"):
		sprite.play("hurt")


func _hurt_update(delta: float) -> void:
	_hurt_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	if _hurt_timer <= 0.0:
		hsm.dispatch(&"recovered")


func _stilled_enter() -> void:
	velocity = Vector2.ZERO
	lunge_hitbox.deactivate()
	# stop reacting to the player's body entirely; remain solid to the world
	collision_mask = 1
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("stilled"):
		sprite.play("stilled")


func _stilled_flag() -> StringName:
	return StringName("stilled_" + String(stable_id))


## Soothing channel (player hold-to-soothe). Returns true when newly Stilled.
func add_recognition(amount: float) -> bool:
	if stilled or not spareable or amount <= 0.0:
		return false
	_soothe_hold = 0.6
	recognition = minf(recognition + amount, RECOGNITION_MAX)
	if recognition < RECOGNITION_MAX:
		return false
	_become_stilled()
	return true


func _become_stilled() -> void:
	stilled = true
	PlayerData.set_story_flag(_stilled_flag())
	PlayerData.change_morality(-5.0)
	DreadManager.reduce_dread(10.0)
	if GameEvents:
		GameEvents.monster_stilled.emit(stable_id)
	hsm.dispatch(&"stilled")


# --- reactions ---

func _on_hit_received(hitbox: Hitbox) -> void:
	if stilled:
		_betrayed()
	velocity = hitbox.global_position.direction_to(global_position) * hitbox.knockback_force
	lunge_hitbox.deactivate()  # interrupted lunge must not keep a live hitbox
	# Re-entering Hurt refreshes the stagger — intended (stun-lock is bounded
	# by Health.invuln_seconds, so hits can't chain faster than 0.2s).
	hsm.dispatch(&"hit")


## Striking a calmed child is the betrayal — the cost lands on the FIRST
## blow, then it wakes and defends itself (encounters-mercy.md).
func _betrayed() -> void:
	stilled = false
	recognition = RECOGNITION_MAX * 0.5  # trust broken, not erased
	collision_mask = 7
	PlayerData.story_flags.erase(_stilled_flag())
	PlayerData.change_morality(20.0)
	PlayerData.add_companion_corruption(&"briar", 10.0)
	if GameEvents:
		GameEvents.stilled_monster_killed.emit(stable_id)


func _on_died() -> void:
	if GameEvents:
		GameEvents.enemy_died.emit(enemy_kind)
	queue_free()


# --- visuals ---

func _update_animation() -> void:
	if sprite.sprite_frames == null:
		return
	if hsm and hsm.get_active_state() in [_state_attack, _state_hurt]:
		return  # state already chose its animation
	if velocity.length() > 4.0:
		_facing = velocity.normalized()
		var anim: Array = PlayerController.directional_anim("walk", _facing)
		sprite.flip_h = anim[1]
		if sprite.sprite_frames.has_animation(anim[0]) and sprite.animation != anim[0]:
			sprite.play(anim[0])
	elif sprite.sprite_frames.has_animation("idle") and sprite.animation != "idle":
		sprite.flip_h = false  # don't leak movement mirroring into poses
		sprite.play("idle")
