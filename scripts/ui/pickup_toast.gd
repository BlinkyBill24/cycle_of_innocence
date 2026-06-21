class_name PickupToast
extends CanvasLayer
## A brief "Found: <item>" notice whenever an item enters the satchel — so a pickup
## (key, flute, forage) is never silent (playtest 2026-06-21: "no indication the flute
## was found"). Player-owned (the player is in EVERY zone, including interiors that have
## no HUD). Light-touch: one fading centred label, no panel; newer replaces older.

const SHOW_SECONDS := 2.2

var _current: Label


func _ready() -> void:
	layer = 55  # above HUD (15) / prompts, below the satchel (60) and dialogue (100)
	process_mode = Node.PROCESS_MODE_ALWAYS
	if GameEvents:
		GameEvents.item_acquired.connect(_on_item_acquired)


func _on_item_acquired(item_id: StringName, qty: int) -> void:
	_show(toast_text(item_id, qty))


## "Found: <display name>" (+ ×N for a stack). Pure/testable; falls back to the id.
static func toast_text(item_id: StringName, qty: int = 1) -> String:
	var def := ItemRegistry.get_def(item_id)
	var item_name: String = def.display_name if def != null and not def.display_name.is_empty() \
			else String(item_id)
	return "Found: %s" % item_name if qty <= 1 else "Found: %s  ×%d" % [item_name, qty]


func _show(text: String) -> void:
	if _current != null and is_instance_valid(_current):
		_current.queue_free()
	var label := Label.new()
	label.text = text
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 28.0
	label.offset_bottom = 56.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.97, 0.93, 0.78))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	_current = label
	label.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.25)
	tween.tween_interval(SHOW_SECONDS)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)
