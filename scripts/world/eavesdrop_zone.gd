class_name EavesdropZone
extends Area2D
## Proximity gossip (village-life.md): standing here unseen floats an
## ambient line keyed to the hollowing stage. Gossip is a systemic lore
## channel — some lines carry real intel. No balloon, no input lock:
## the village talks PAST Rowan, never to them.

@export var source_npc_id: StringName = &""  # high suspicion changes the line
@export var cooldown_seconds: float = 12.0

var _cooldown := 0.0
var _label: Label


func _ready() -> void:
	add_to_group("eavesdrop")
	monitoring = true
	collision_mask = 2  # player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		VillageState.player_eavesdropping = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	VillageState.player_eavesdropping = true  # caught HERE is worse
	if _cooldown > 0.0:
		return
	_cooldown = cooldown_seconds
	var suspicious := not source_npc_id.is_empty() \
			and VillageState.get_suspicion(source_npc_id) > 60.0
	var line := VillageState.pick_gossip(HollowingClock.stage, suspicious)
	if not line.is_empty():
		_float_text(line)


func _float_text(text: String) -> void:
	if _label == null:
		_label = Label.new()
		_label.add_theme_font_size_override("font_size", 10)
		_label.add_theme_color_override("font_color", Color(0.85, 0.83, 0.75))
		_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		_label.add_theme_constant_override("outline_size", 3)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(_label)
	_label.text = "\"%s\"" % text
	_label.modulate.a = 0.0
	_label.position = Vector2(-_label.size.x / 2.0, -40)
	_label.visible = true
	var tween := create_tween()
	tween.tween_property(_label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.2)
	tween.tween_property(_label, "modulate:a", 0.0, 0.8)
