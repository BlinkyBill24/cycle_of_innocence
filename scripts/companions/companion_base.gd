class_name CompanionBase
extends CharacterBody2D
## Companion AI (Briar first): LimboHSM follow / sit / dig / cower / bark.
## Fear is driven by the global dread tier; assists are gated by bond and fear
## (docs/characters/companions.md + DreadManager.get_companion_reliability()).

signal assist_completed(kind: StringName)
signal assist_refused(reason: StringName)

@export var companion_id: StringName = &"briar"
@export var follow_distance: float = 26.0
@export var catchup_distance: float = 70.0
@export var move_speed: float = 90.0
@export var run_speed: float = 135.0
@export var bark_radius: float = 95.0
@export var bark_cooldown_seconds: float = 6.0
@export var min_assist_bond: float = 10.0
@export var dig_seconds: float = 1.2
@export var dig_bond_reward: float = 2.0

## Quirk expression (companion-quirks.md): acquired quirks live on PlayerData;
## this layer is HOW they show. Authored behaviors only — see CompanionQuirkDefs.
const SCENT_RANGE := 90.0
const QUIRK_COOLDOWN := 20.0
const STARE_SECONDS := 0.9
const STARE_SOFTENED_BOND := 60.0  # earned trust: stare becomes a head-bump
const DUSK_PRESS_DREAD_RELIEF := 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var hsm: LimboHSM
var _dig_target: Node2D
var _dig_phase_digging := false
var _dig_timer := 0.0
var _bark_timer := 0.0
var _bark_cooldown := 0.0
var _facing: Vector2 = Vector2.DOWN

var _state_follow: LimboState
var _state_dig: LimboState
var _state_cower: LimboState
var _state_bark: LimboState
var _state_quirk: LimboState

var _paused := false  # quirks freeze during cutscenes/dialogue
var _quirk_cooldown := 0.0
var _quirk_point := Vector2.ZERO
var _quirk_truth := false
var _quirk_id: StringName
var _quirk_timer := 0.0
var _phantom_timer := 0.0
var _stare_timer := 0.0
var _calm_hold := 0.0  # >0 while anchoring the player's soothe (lie_down)


func _ready() -> void:
	add_to_group("companion")
	add_to_group(String(companion_id))
	DreadManager.dread_tier_changed.connect(_on_dread_tier_changed)
	WorldState.time_changed.connect(_on_time_changed)
	if GameEvents:
		GameEvents.exploration_paused.connect(func() -> void: _paused = true)
		GameEvents.exploration_resumed.connect(func() -> void: _paused = false)
	_phantom_timer = randf_range(15.0, 30.0)
	_init_hsm()


func _on_time_changed(time: int, _day: int) -> void:
	# dusk restlessness: the "let's go home" cue comes from family, not UI
	if time == WorldState.TimeOfDay.DUSK or time == WorldState.TimeOfDay.NIGHT:
		Sfx.play(&"whimper", -6.0)
		# dusk press (bond quirk): as the dark comes, the family holds
		if PlayerData.has_quirk(companion_id, &"briar_dusk_press") \
				and not _paused and not is_afraid():
			DreadManager.reduce_dread(DUSK_PRESS_DREAD_RELIEF)
			Sfx.play(&"bark", -6.0)
			if GameEvents:
				GameEvents.quirk_expressed.emit(companion_id, &"briar_dusk_press")


func _init_hsm() -> void:
	hsm = LimboHSM.new()
	add_child(hsm)

	_state_follow = LimboState.new().named("Follow").call_on_update(_follow_update)
	_state_dig = LimboState.new().named("Dig") \
		.call_on_enter(_dig_enter).call_on_update(_dig_update)
	_state_cower = LimboState.new().named("Cower") \
		.call_on_enter(_cower_enter).call_on_update(_cower_update)
	_state_bark = LimboState.new().named("Bark") \
		.call_on_enter(_bark_enter).call_on_update(_bark_update)
	_state_quirk = LimboState.new().named("Quirk") \
		.call_on_enter(_quirk_enter).call_on_update(_quirk_update)

	for state: LimboState in [_state_follow, _state_dig, _state_cower, _state_bark, _state_quirk]:
		hsm.add_child(state)

	hsm.add_transition(_state_follow, _state_dig, &"dig")
	hsm.add_transition(_state_dig, _state_follow, &"done")
	hsm.add_transition(_state_follow, _state_bark, &"alert")
	hsm.add_transition(_state_bark, _state_follow, &"done")
	hsm.add_transition(_state_follow, _state_quirk, &"quirk")
	hsm.add_transition(_state_quirk, _state_follow, &"done")
	hsm.add_transition(hsm.ANYSTATE, _state_cower, &"afraid")
	hsm.add_transition(_state_cower, _state_follow, &"calmed")

	hsm.initial_state = _state_follow
	hsm.initialize(self)
	hsm.set_active(true)
	# spawning into an already-terrified world must start cowering (Codex gate #1)
	if is_afraid():
		hsm.dispatch(&"afraid")


func _physics_process(delta: float) -> void:
	_bark_cooldown = maxf(_bark_cooldown - delta, 0.0)
	_quirk_cooldown = maxf(_quirk_cooldown - delta, 0.0)
	_calm_hold = maxf(_calm_hold - delta, 0.0)
	move_and_slide()
	_update_animation()


func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func is_afraid() -> bool:
	return DreadManager.get_tier() >= DreadManager.DreadTier.FEARFUL


func get_bond() -> float:
	return PlayerData.get_companion(companion_id).bond


## Public assist entry point (player interact). Returns false when refused —
## fear and low bond both make the family unreliable, which is the design.
func command_dig(spot: Node2D) -> bool:
	if spot == null:
		return false
	# fear first: a cowering companion REFUSES (visible feedback), it doesn't
	# silently ignore — that ambiguity would read as a bug, not as fear
	if is_afraid() or hsm.get_active_state() == _state_cower:
		Sfx.play(&"whimper", -6.0)
		assist_refused.emit(&"afraid")
		return false
	if hsm.get_active_state() != _state_follow:
		return false  # busy (already digging/barking)
	if get_bond() < min_assist_bond:
		assist_refused.emit(&"low_bond")
		return false
	_dig_target = spot
	hsm.dispatch(&"dig")
	return true


# --- states ---

func _follow_update(_delta: float) -> void:
	var player := get_player()
	if player == null:
		velocity = Vector2.ZERO
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > follow_distance:
		var speed := run_speed if dist > catchup_distance else move_speed
		velocity = global_position.direction_to(player.global_position) * speed
	else:
		velocity = Vector2.ZERO
	_maybe_express_quirks(_delta)
	_maybe_bark()


func _maybe_bark() -> void:
	if _bark_cooldown > 0.0:
		return
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var node := enemy as Node2D
		if node and not (node is EnemyBase and (node.stilled or node.dominated)) \
				and global_position.distance_to(node.global_position) <= bark_radius:
			hsm.dispatch(&"alert")
			return


func _dig_enter() -> void:
	_dig_phase_digging = false
	_dig_timer = dig_seconds
	_stare_timer = 0.0
	# corruption quirk: the order lands, but something looks back at you first.
	# Earned bond softens it into a head-bump — visibly changed, never removed.
	if PlayerData.has_quirk(companion_id, &"briar_long_stare"):
		if get_bond() >= STARE_SOFTENED_BOND:
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("head_bump"):
				sprite.play("head_bump")
			var hop := create_tween()
			hop.tween_property(sprite, "position:y", -5.0, 0.1)
			hop.tween_property(sprite, "position:y", 0.0, 0.1)
		else:
			_stare_timer = STARE_SECONDS
		if GameEvents:
			GameEvents.quirk_expressed.emit(companion_id, &"briar_long_stare")


func _dig_update(delta: float) -> void:
	if _dig_target == null or not is_instance_valid(_dig_target):
		hsm.dispatch(&"done")
		return
	if _stare_timer > 0.0:  # the beat-too-long stare before complying
		_stare_timer -= delta
		velocity = Vector2.ZERO
		var player := get_player()
		if player:
			_facing = global_position.direction_to(player.global_position)
		return
	if not _dig_phase_digging:
		if global_position.distance_to(_dig_target.global_position) > 10.0:
			velocity = global_position.direction_to(_dig_target.global_position) * run_speed
			return
		_dig_phase_digging = true
		velocity = Vector2.ZERO
		Sfx.play(&"dig", -4.0)
		if sprite.sprite_frames and sprite.sprite_frames.has_animation("dig"):
			sprite.play("dig")
		return
	_dig_timer -= delta
	if _dig_timer <= 0.0:
		# reward only a real reveal — if something else uncovered the spot
		# mid-dig there is no shared success moment (Codex gate #3)
		if _dig_target.has_method("reveal") and _dig_target.reveal():
			PlayerData.set_companion_bond(companion_id, get_bond() + dig_bond_reward)
			assist_completed.emit(&"dig")
		_dig_target = null
		hsm.dispatch(&"done")


func _cower_enter() -> void:
	velocity = Vector2.ZERO
	_dig_target = null
	Sfx.play(&"whimper", -4.0)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("cower"):
		sprite.play("cower")


func _cower_update(_delta: float) -> void:
	velocity = Vector2.ZERO
	if not is_afraid():
		hsm.dispatch(&"calmed")


const EXCLAIM_TEX := preload("res://assets/sprites/ui/exclaim.png")
var _exclaim: Sprite2D


func _bark_enter() -> void:
	velocity = Vector2.ZERO
	_bark_timer = 0.9
	_bark_cooldown = bark_cooldown_seconds
	Sfx.play(&"bark", 2.0)
	get_tree().create_timer(0.35).timeout.connect(func() -> void: Sfx.play(&"bark", 1.0))
	_show_exclaim()
	# small hop: the body language reads even without sound
	var hop := create_tween()
	hop.tween_property(sprite, "position:y", -6.0, 0.12)
	hop.tween_property(sprite, "position:y", 0.0, 0.12)
	hop.tween_property(sprite, "position:y", -4.0, 0.1)
	hop.tween_property(sprite, "position:y", 0.0, 0.1)


func _show_exclaim() -> void:
	if _exclaim == null:
		_exclaim = Sprite2D.new()
		_exclaim.texture = EXCLAIM_TEX
		_exclaim.position = Vector2(0, -22)
		_exclaim.scale = Vector2(2, 2)
		add_child(_exclaim)
	_exclaim.visible = true
	_exclaim.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(0.9)
	tween.tween_property(_exclaim, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func() -> void: _exclaim.visible = false)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("bark"):
		sprite.play("bark")
	if GameEvents:
		GameEvents.companion_bark.emit(companion_id)


func _bark_update(delta: float) -> void:
	_bark_timer -= delta
	if _bark_timer <= 0.0:
		hsm.dispatch(&"done")


# --- quirk expression ---

func _maybe_express_quirks(delta: float) -> void:
	if _paused or is_afraid() or _quirk_cooldown > 0.0:
		return
	# scent growl (bond quirk): a TRUE ping at buried things — learn to trust it
	if PlayerData.has_quirk(companion_id, &"briar_scent_growl"):
		var spot := _nearest_unrevealed_diggable()
		if spot:
			_express_ping(spot.global_position, true, &"briar_scent_growl")
			return
	# phantom guard (deep corruption): the same growl at NOTHING — the player
	# can no longer tell which warnings are real
	if PlayerData.has_quirk(companion_id, &"briar_phantom_guard"):
		_phantom_timer -= delta
		if _phantom_timer <= 0.0:
			_phantom_timer = randf_range(15.0, 30.0)
			var dir := Vector2.RIGHT.rotated(randf() * TAU)
			_express_ping(global_position + dir * randf_range(40.0, 70.0), false,
					&"briar_phantom_guard")


func _nearest_unrevealed_diggable() -> DiggableSpot:
	var nearest: DiggableSpot = null
	var best := SCENT_RANGE
	for node in get_tree().get_nodes_in_group("diggable"):
		var spot := node as DiggableSpot
		if spot and not spot.revealed:
			var dist := global_position.distance_to(spot.global_position)
			if dist < best:
				best = dist
				nearest = spot
	return nearest


func _express_ping(point: Vector2, truth: bool, quirk_id: StringName) -> void:
	_quirk_point = point
	_quirk_truth = truth
	_quirk_id = quirk_id
	_quirk_cooldown = QUIRK_COOLDOWN
	hsm.dispatch(&"quirk")


func _quirk_enter() -> void:
	velocity = Vector2.ZERO
	_quirk_timer = 1.6
	_facing = global_position.direction_to(_quirk_point)
	Sfx.play(&"growl", -2.0)
	var anim: Array = PlayerController.directional_anim("growl", _facing)
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim[0]):
		sprite.play(anim[0])  # hackles up, fixed on the point
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("bark"):
		sprite.play("bark")  # pre-redesign fallback
	# Empath insight: only the Innocent, with earned bond, can tell true
	# warnings from corrupted ones; a Vessel sees nothing wrong at all
	if insight_tell_visible(_quirk_truth, PlayerData.get_morality_tier(), get_bond()):
		_show_exclaim()
	if GameEvents:
		GameEvents.quirk_expressed.emit(companion_id, _quirk_id)


func _quirk_update(delta: float) -> void:
	velocity = Vector2.ZERO
	_quirk_timer -= delta
	if _quirk_timer <= 0.0:
		hsm.dispatch(&"done")


## Per-frame anchor while the player soothes nearby: Briar lies down
## non-threateningly (encounters-mercy.md companion assist).
func show_calm() -> void:
	_calm_hold = 0.3


## Pure tell rule (companion-quirks.md), unit-tested.
static func insight_tell_visible(is_true_ping: bool, tier: int, bond: float) -> bool:
	return is_true_ping and tier == PlayerData.MoralityTier.INNOCENT_EMPATH \
			and bond >= STARE_SOFTENED_BOND


func _on_dread_tier_changed(_tier: int) -> void:
	if is_afraid() and hsm and hsm.get_active_state() != _state_cower:
		hsm.dispatch(&"afraid")


# --- visuals ---

func _update_animation() -> void:
	if sprite.sprite_frames == null:
		return
	if hsm and hsm.get_active_state() in [_state_cower, _state_bark]:
		return
	if hsm and hsm.get_active_state() == _state_dig and _dig_phase_digging:
		return
	if _calm_hold > 0.0 and velocity.length() <= 4.0 \
			and sprite.sprite_frames.has_animation("lie_down"):
		if sprite.animation != "lie_down":
			sprite.play("lie_down")
		return
	if velocity.length() > 4.0:
		_facing = velocity.normalized()
		var anim: Array = PlayerController.directional_anim("trot", _facing)
		sprite.flip_h = anim[1]
		if sprite.sprite_frames.has_animation(anim[0]) and sprite.animation != anim[0]:
			sprite.play(anim[0])
	elif sprite.sprite_frames.has_animation("sit") and sprite.animation != "sit":
		sprite.flip_h = false  # don't leak movement mirroring into poses
		sprite.play("sit")
