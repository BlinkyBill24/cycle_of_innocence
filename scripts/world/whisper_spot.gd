class_name WhisperSpot
extends Area2D
## A line the world says to Rowan once, on approach — perception-class
## recontext decor (zone-recontextualization.md). Pair with a
## `recontext_<revelation_id>` group so the whisper only exists once the
## player knows what they are looking at.

@export var spot_id: StringName = &"unnamed_whisper"
@export_multiline var text: String = ""
@export var dread_on_hear: float = 0.0
## Optional Journal payload: when set, witnessing the whisper also records an
## observed-sign entry (secrets-and-discovery / doom legibility). The floating
## whisper is atmosphere; this is Rowan's recorded inference. DOOM by default
## (a sign of the net closing) — set to LORE for a perception fragment.
@export_multiline var journal_text: String = ""
@export_enum("Lore", "Doom") var journal_kind: int = 1

var _label: Label
var _fired := false


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_trigger()


## A recontext-gated whisper (e.g. recontext_stage_1) is process-disabled until
## its condition flips — and an Area2D does NOT emit body_entered for a body
## already inside it when monitoring resumes (playtest 2026-06-13: the stage-1
## doom sign never fired its journal entry). So poll for an overlapping player
## once active; this only runs while the node is enabled.
func _physics_process(_delta: float) -> void:
	if _fired:
		set_physics_process(false)
		return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_trigger()
			return


func _trigger() -> void:
	if _fired:
		return
	var flag := StringName("whispered_" + String(spot_id))
	if PlayerData.has_story_flag(flag):
		_fired = true
		return
	_fired = true
	PlayerData.set_story_flag(flag)
	if dread_on_hear > 0.0:
		DreadManager.add_dread(dread_on_hear, &"whisper")
	if not journal_text.is_empty():
		Journal.witness(StringName("sign_" + String(spot_id)), journal_text, journal_kind)
	_float_text()


func _float_text() -> void:
	if text.is_empty():
		return
	_label = Label.new()
	_label.text = text
	_label.add_theme_font_size_override("font_size", 10)
	_label.add_theme_color_override("font_color", Color(0.8, 0.74, 0.86))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 3)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	_label.position = Vector2(-_label.size.x / 2.0, -36)
	_label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_label, "modulate:a", 1.0, 0.6)
	tween.tween_interval(3.5)
	tween.tween_property(_label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(_label.queue_free)
