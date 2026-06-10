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


func _ready() -> void:
	add_to_group("companion")
	add_to_group(String(companion_id))
	DreadManager.dread_tier_changed.connect(_on_dread_tier_changed)
	WorldState.time_changed.connect(_on_time_changed)
	_init_hsm()


func _on_time_changed(time: int, _day: int) -> void:
	# dusk restlessness: the "let's go home" cue comes from family, not UI
	if time == WorldState.TimeOfDay.DUSK or time == WorldState.TimeOfDay.NIGHT:
		Sfx.play(&"whimper", -6.0)


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

	for state: LimboState in [_state_follow, _state_dig, _state_cower, _state_bark]:
		hsm.add_child(state)

	hsm.add_transition(_state_follow, _state_dig, &"dig")
	hsm.add_transition(_state_dig, _state_follow, &"done")
	hsm.add_transition(_state_follow, _state_bark, &"alert")
	hsm.add_transition(_state_bark, _state_follow, &"done")
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


func _dig_update(delta: float) -> void:
	if _dig_target == null or not is_instance_valid(_dig_target):
		hsm.dispatch(&"done")
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
	if velocity.length() > 4.0:
		_facing = velocity.normalized()
		var anim: Array = PlayerController.directional_anim("trot", _facing)
		sprite.flip_h = anim[1]
		if sprite.sprite_frames.has_animation(anim[0]) and sprite.animation != anim[0]:
			sprite.play(anim[0])
	elif sprite.sprite_frames.has_animation("sit") and sprite.animation != "sit":
		sprite.flip_h = false  # don't leak movement mirroring into poses
		sprite.play("sit")
