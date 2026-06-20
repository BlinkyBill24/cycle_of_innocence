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

## Interface horror (interface-horror.md): under pressure the body resists —
## brief input-lag pulses, ONE eaten attack press per spike, walk hitching.
## Presentation only (no mechanical consequence); never longer than 2s; off
## below the intensity gate and on poor frame rates (mobile contract).
const SPIKE_MAX_SECONDS := 2.0
const SPIKE_MIN_SECONDS := 0.8
const SPIKE_COOLDOWN_SECONDS := 9.0
const SPIKE_MIN_FPS := 45.0
const SPIKE_HITCH_FACTOR := 0.8

var movement_state: MovementState = MovementState.EXPLORING
var age_stage: AgeStage = AgeStage.CHILD
var morality: float = 0.0
var _facing: Vector2 = Vector2.DOWN
var _action_anim_lock: bool = false
var _footstep_timer: float = 0.0
var _input_grace: float = 0.0

var _spike_timer := 0.0
var _spike_cooldown := 0.0
var _spike_lag_frames := 0
var _spike_ate_press := false
var _spike_prev_speed_scale := 1.0
var _lag_buffer: Array[Vector2] = []

const SOOTHE_RANGE := 80.0
const SOOTHE_RATE := 30.0  # recognition per second (≈3.3s to Still)
const SOOTHE_KEY_BONUS := 1.6  # the child's specific key (encounters-mercy.md)
const BRIAR_CALM_BONUS := 1.5  # Briar lying down non-threateningly nearby
const BRIAR_CALM_MIN_BOND := 25.0
const BRIAR_CALM_RANGE := 90.0
const DOMINATE_RATE_FACTOR := 1.4  # fear is faster than trust — by design
var _soothing := false
var _soothe_prompt: SoothePrompt
var _soothe_target: EnemyBase

func _ready() -> void:
	_soothe_prompt = SoothePrompt.new()
	add_child(_soothe_prompt)
	add_child(JournalPanel.new())  # J toggles the observed-signs journal
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
	if PlayerData.spawn_position == Vector2.ZERO:
		PlayerData.spawn_position = global_position  # death respawn = scene spawn
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
	_update_soothe_prompt()
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

	_update_interface_spike(delta)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _spike_timer > 0.0:
		input_vector = _lagged_input(input_vector)

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
		if not _spike_eats_press():
			perform_attack()

	if Input.is_action_just_pressed("interact") and movement_state == MovementState.EXPLORING:
		_on_interact_pressed()

	# recall: ask the companion to (re-)point at what it last sought. Decoupled —
	# the companion / quest decide the target (docs/mechanics/companion-pointer.md).
	if Input.is_action_just_pressed("recall_companion") and movement_state == MovementState.EXPLORING:
		GameEvents.companion_recalled.emit()

func _decelerate(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _update_footsteps(delta: float) -> void:
	if velocity.length() < 30.0:
		_footstep_timer = 0.12
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		Sfx.play(footstep_sound(_current_surface()), -10.0, 0.12)
		_footstep_timer = 0.34


## Surface under the player's feet — the last gravel/path SurfaceZone entered,
## else grass (the default ground). Rough; zone placement is an editor pass.
func _current_surface() -> StringName:
	for node in get_tree().get_nodes_in_group("surface_zone"):
		var zone := node as SurfaceZone
		if zone and zone.has_player():
			return zone.surface
	return &"grass"


## Map a surface name to its Sfx key. Static + pure (testable). Unknown
## surfaces fall back to grass (the `footstep` key). Hard surfaces (gravel/path/
## sand/wood) share the one "hard" footstep sample for now — a dedicated wood
## sample is a future audio pass; wood reads as the hard step, distinct from grass.
static func footstep_sound(surface: StringName) -> StringName:
	match surface:
		&"gravel", &"path", &"sand", &"wood":
			return &"footstep_gravel"
		_:
			return &"footstep"


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


## An UNspareable, live monster in soothe range — the emergency-ritual child.
## Drives the "too far gone" cue so its un-soothability reads as the intended
## horror beat, not a broken verb (playtest 2026-06-13).
func _unspareable_monster_near() -> bool:
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as EnemyBase
		if enemy and not enemy.spareable and not enemy.stilled \
				and global_position.distance_to(enemy.global_position) < SOOTHE_RANGE:
			return true
	return false


## Soothe affordance (playtest tester-01): the hold verb must be readable
## without the debug HUD — hint when near, progress while holding.
func _update_soothe_prompt() -> void:
	if _soothe_prompt == null:
		return
	if movement_state != MovementState.EXPLORING:
		_soothe_prompt.update_state(false, false, 0.0)
		return
	if _soothing and _soothe_target != null and is_instance_valid(_soothe_target):
		# domination (Vessel) reuses the recognition field — one bar serves both
		var ratio: float = _soothe_target.recognition / EnemyBase.RECOGNITION_MAX
		var has_key := PlayerData.has_story_flag(_soothe_target.soothe_key_flag)
		var stalled := not has_key \
				and PlayerData.get_morality_tier() != PlayerData.MoralityTier.VESSEL \
				and _soothe_target.recognition >= EnemyBase.GENERIC_PLATEAU - 0.5
		_soothe_prompt.update_state(false, true, ratio, stalled)
		return
	var spareable_near := _nearest_spareable_monster() != null
	var too_far_gone := not spareable_near and _unspareable_monster_near()
	_soothe_prompt.update_state(spareable_near, false, 0.0, false, too_far_gone)


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
	if companion:
		if nearest:
			companion.command_dig(nearest)
		elif nearest_revealed:
			# standing on dug-up earth: answer the press so silence never reads as
			# a bug — there is just nothing left buried here (playtest 2026-06-11)
			companion.signal_nothing_to_dig()
	elif nearest:
		# no-missable fallback (Fable model, docs/mechanics/companion-pointer.md):
		# with no dog to dig, Rowan uncovers it by hand — content is never gated
		# behind the companion alone.
		nearest.reveal()

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

# --- interface horror spikes ---

func _update_interface_spike(delta: float) -> void:
	_spike_cooldown = maxf(_spike_cooldown - delta, 0.0)
	if _spike_timer > 0.0:
		_spike_timer -= delta
		if _spike_timer <= 0.0:
			_end_spike()
		return
	var pressure: float = DreadManager.interface_pressure()
	if pressure <= 0.0 or _spike_cooldown > 0.0:
		return
	if Engine.get_frames_per_second() < SPIKE_MIN_FPS:
		return  # input already heavy — never stack (accessibility contract)
	if randf() < pressure * delta * 0.6:
		start_interface_spike(pressure)


func start_interface_spike(pressure: float) -> void:
	_spike_timer = lerpf(SPIKE_MIN_SECONDS, SPIKE_MAX_SECONDS, clampf(pressure, 0.0, 1.0))
	_spike_cooldown = SPIKE_COOLDOWN_SECONDS
	_spike_lag_frames = 1 + int(round(clampf(pressure, 0.0, 1.0) * 2.0))  # 1-3
	_spike_ate_press = false
	_lag_buffer.clear()
	if animated_sprite:
		_spike_prev_speed_scale = animated_sprite.speed_scale
		animated_sprite.speed_scale = _spike_prev_speed_scale * SPIKE_HITCH_FACTOR


func _end_spike() -> void:
	_spike_timer = 0.0
	_lag_buffer.clear()
	if animated_sprite:
		animated_sprite.speed_scale = _spike_prev_speed_scale


## The hand hesitates — at most one attack press dies per spike.
func _spike_eats_press() -> bool:
	if _spike_timer > 0.0 and not _spike_ate_press:
		_spike_ate_press = true
		return true
	return false


## 1-3 frames of input latency while a spike runs (the doc's latency pulse).
func _lagged_input(raw: Vector2) -> Vector2:
	_lag_buffer.push_back(raw)
	if _lag_buffer.size() > _spike_lag_frames:
		return _lag_buffer.pop_front()
	return Vector2.ZERO


var _attack_id := 0

const PROJECTILE_SCENE := preload("res://scenes/combat/thrown_projectile.tscn")
const THROW_REACH := 12.0


## The equipped weapon's combat kind (pure, testable): true when the attack
## should throw (ranged) rather than swing (melee). Bare hands / EQUIP = swing.
static func attack_is_throw(def: ItemDef) -> bool:
	return def != null and def.use_kind == ItemDef.UseKind.THROW


## Spend one ammo for a throw. Returns false (blocked, no decrement) when the
## weapon has no ammo id or the satchel is out. Pure side effect on Inventory.
static func consume_throw_ammo(ammo_id: StringName) -> bool:
	if ammo_id == &"" or Inventory.quantity_of(ammo_id) <= 0:
		return false
	return Inventory.remove(ammo_id, 1)


func perform_attack() -> void:
	var weapon_def := ItemRegistry.get_def(PlayerData.equipped_weapon) \
			if PlayerData.equipped_weapon != &"" else null
	if attack_is_throw(weapon_def):
		_perform_throw(weapon_def)
		return
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


## Slingshot attack: spend one stone and loose a projectile in the facing
## direction. Blocked (a soft click, no shot) when out of ammo.
func _perform_throw(def: ItemDef) -> void:
	if not consume_throw_ammo(def.ammo_id):
		Sfx.play(&"swing", -16.0)  # dry click — the sling is empty
		return
	play_action_animation("attack")
	Sfx.play(&"swing", -6.0)
	var proj: ThrownProjectile = PROJECTILE_SCENE.instantiate()
	proj.setup(_facing, 1)  # parity with the melee hitbox; gear stat-weight is the equipment pass
	proj.global_position = global_position + _facing * THROW_REACH
	# into the zone's world container so it y-sorts/lives with everyone else
	var world := get_parent()
	(world if world else get_tree().current_scene).add_child(proj)


func _on_hit_received(from_hitbox: Hitbox) -> void:
	attack_hitbox.deactivate()  # interrupted attacks must not leave a live hitbox
	if _soothing:
		_stop_soothe()  # the channel breaks when the world bites back
	set_movement_state(MovementState.HURT)
	velocity = from_hitbox.global_position.direction_to(global_position) * from_hitbox.knockback_force
	if animated_sprite:
		animated_sprite.modulate = Color(1.0, 0.5, 0.5)
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("hurt"):
			_action_anim_lock = true
			animated_sprite.play("hurt")
	DreadManager.add_dread(HURT_DREAD, &"player_hurt")
	await get_tree().create_timer(HURT_SECONDS).timeout
	if animated_sprite:
		animated_sprite.modulate = Color.WHITE
	if movement_state == MovementState.HURT:
		movement_state = MovementState.EXPLORING
		_action_anim_lock = false
		_update_locomotion_animation()


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
