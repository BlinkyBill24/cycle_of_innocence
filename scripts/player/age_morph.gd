class_name AgeMorph
extends Node
## Rowan visual morph — age silhouette + morality tint + "marked" shader stub.
## Vertical slice: child sprites only; teen/adult use scale/modulate until sheets exist.

@export var visual_target: CanvasItem
@export var child_frames: SpriteFrames
@export var teen_frames: SpriteFrames
@export var adult_frames: SpriteFrames
@export var marked_shader: Shader

const AGE_BASE_SCALE := {
	PlayerData.AgeStage.CHILD: 1.0,
	PlayerData.AgeStage.TEEN: 1.18,
	PlayerData.AgeStage.ADULT: 1.32,
}

const INNOCENT_TINT := Color(1.05, 1.02, 0.96, 1.0)
const WOUNDED_TINT := Color(1.0, 1.0, 1.0, 1.0)
const HARDENED_TINT := Color(0.88, 0.86, 0.9, 1.0)
const VESSEL_TINT := Color(0.78, 0.72, 0.82, 1.0)

var _base_scale: Vector2 = Vector2.ONE
var _shader_material: ShaderMaterial


func _ready() -> void:
	if child_frames == null:
		child_frames = _build_slice_frames()
	if visual_target == null:
		visual_target = _find_visual_target()
	if visual_target:
		_base_scale = visual_target.scale
	_connect_player_data()
	apply_visual_state(PlayerData.age_stage, PlayerData.morality, PlayerData.companions)


func _connect_player_data() -> void:
	PlayerData.age_advanced.connect(_on_age_advanced)
	PlayerData.morality_changed.connect(_on_morality_changed)
	PlayerData.bond_changed.connect(_on_companion_state_changed)
	PlayerData.corruption_changed.connect(_on_companion_state_changed)


func apply_visual_state(
	age: PlayerData.AgeStage,
	morality_value: float,
	companion_states: Dictionary
) -> void:
	if visual_target == null:
		return
	_apply_age_frames(age)
	_apply_age_scale(age)
	_apply_morality_visuals(morality_value)
	_apply_briar_echo_stub(companion_states)


func _apply_age_frames(age: PlayerData.AgeStage) -> void:
	if not visual_target is AnimatedSprite2D:
		return
	var sprite := visual_target as AnimatedSprite2D
	var frames := _frames_for_age(age)
	if frames == null:
		return
	if sprite.sprite_frames == frames:
		return
	var current_anim := sprite.animation
	sprite.sprite_frames = frames
	if frames.has_animation(current_anim):
		sprite.play(current_anim)
	elif frames.get_animation_names().size() > 0:
		sprite.play(frames.get_animation_names()[0])


func _frames_for_age(age: PlayerData.AgeStage) -> SpriteFrames:
	match age:
		PlayerData.AgeStage.TEEN:
			return teen_frames if teen_frames else child_frames
		PlayerData.AgeStage.ADULT:
			return adult_frames if adult_frames else child_frames
		_:
			return child_frames


func _apply_age_scale(age: PlayerData.AgeStage) -> void:
	var factor: float = AGE_BASE_SCALE.get(age, 1.0)
	visual_target.scale = _base_scale * factor
	# Child Rowan is light-footed; teen/adult feel heavier (bible: loss of innocence).
	if visual_target is AnimatedSprite2D:
		var speed_scale := 1.0
		match age:
			PlayerData.AgeStage.TEEN:
				speed_scale = 0.95
			PlayerData.AgeStage.ADULT:
				speed_scale = 0.9
		(visual_target as AnimatedSprite2D).speed_scale = speed_scale


func _apply_morality_visuals(morality_value: float) -> void:
	var tier := _tier_from_value(morality_value)
	var tint := WOUNDED_TINT
	var corruption_strength := 0.0
	match tier:
		PlayerData.MoralityTier.INNOCENT_EMPATH:
			tint = INNOCENT_TINT
		PlayerData.MoralityTier.WOUNDED:
			tint = WOUNDED_TINT
		PlayerData.MoralityTier.HARDENED:
			tint = HARDENED_TINT
			corruption_strength = 0.35
		PlayerData.MoralityTier.VESSEL:
			tint = VESSEL_TINT
			corruption_strength = 0.75
	# Blend accent from character creation (ribbon/cloak trim).
	tint = tint.lerp(PlayerData.chosen_accent_color, 0.08)
	visual_target.modulate = tint
	_apply_marked_shader(corruption_strength)


func _apply_marked_shader(strength: float) -> void:
	if marked_shader == null:
		if visual_target.material is ShaderMaterial:
			visual_target.material = null
		return
	if _shader_material == null:
		_shader_material = ShaderMaterial.new()
		_shader_material.shader = marked_shader
		visual_target.material = _shader_material
	_shader_material.set_shader_parameter("corruption_strength", strength)


func _apply_briar_echo_stub(companion_states: Dictionary) -> void:
	# Slice hook: Briar corruption could tint Rowan's shadow later; log for debug only.
	if not companion_states.has(PlayerData.BRIAR_ID):
		return
	var briar: Dictionary = companion_states[PlayerData.BRIAR_ID]
	var briar_corruption: float = briar.get("corruption", 0.0)
	if briar_corruption > 40.0 and _shader_material:
		var extra: float = clampf((briar_corruption - 40.0) / 60.0, 0.0, 0.2)
		var current: float = _shader_material.get_shader_parameter("corruption_strength")
		_shader_material.set_shader_parameter("corruption_strength", maxf(current, extra))


func _tier_from_value(value: float) -> PlayerData.MoralityTier:
	if value <= PlayerData.TIER_INNOCENT_MAX:
		return PlayerData.MoralityTier.INNOCENT_EMPATH
	if value <= PlayerData.TIER_WOUNDED_MAX:
		return PlayerData.MoralityTier.WOUNDED
	if value <= PlayerData.TIER_HARDENED_MAX:
		return PlayerData.MoralityTier.HARDENED
	return PlayerData.MoralityTier.VESSEL


func _on_age_advanced(new_stage: int) -> void:
	apply_visual_state(new_stage as PlayerData.AgeStage, PlayerData.morality, PlayerData.companions)


func _on_morality_changed(new_value: float, _delta: float) -> void:
	apply_visual_state(PlayerData.age_stage, new_value, PlayerData.companions)


func _on_companion_state_changed(_companion_id: StringName, _value: float) -> void:
	apply_visual_state(PlayerData.age_stage, PlayerData.morality, PlayerData.companions)


func _build_slice_frames() -> SpriteFrames:
	# Fallback only — the scene normally assigns child_frames in player.tscn.
	return load("res://assets/resources/player/rowan_child_frames.tres") as SpriteFrames


func _find_visual_target() -> CanvasItem:
	var parent_node := get_parent()
	if parent_node == null:
		return null
	if parent_node is CanvasItem:
		for child in parent_node.get_children():
			if child is AnimatedSprite2D:
				return child as CanvasItem
			if child is Sprite2D:
				return child as CanvasItem
	return null
