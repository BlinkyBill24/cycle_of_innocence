class_name WhisperSpot
extends Area2D
## A line the world says to Rowan once, on approach — perception-class
## recontext decor (zone-recontextualization.md). Pair with a
## `recontext_<revelation_id>` group so the whisper only exists once the
## player knows what they are looking at.

@export var spot_id: StringName = &"unnamed_whisper"
@export_multiline var text: String = ""
@export var dread_on_hear: float = 0.0

var _label: Label


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var flag := StringName("whispered_" + String(spot_id))
	if PlayerData.has_story_flag(flag):
		return
	PlayerData.set_story_flag(flag)
	if dread_on_hear > 0.0:
		DreadManager.add_dread(dread_on_hear, &"whisper")
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
