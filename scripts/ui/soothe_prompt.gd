class_name SoothePrompt
extends CanvasLayer
## Soothe affordance (playtest 2026-06-12, tester-01): "pressing E instead of
## holding it" — the hold-to-soothe verb had NO on-screen communication and
## recognition progress was only visible on the (tester-disabled) debug HUD.
## Shows "HOLD E" near a spareable monster and a thin recognition bar while
## the hold is active. Hidden during dialogue/cutscenes.

const BAR_SIZE := Vector2(120, 5)

var _label: Label
var _bar_back: ColorRect
var _bar_fill: ColorRect
var _paused := false


func _ready() -> void:
	layer = 15  # HUD layer — under dialogue (100), over the world
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 3)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_label.offset_bottom = -42.0
	_bar_back = ColorRect.new()
	_bar_back.color = Color(0, 0, 0, 0.55)
	add_child(_bar_back)
	_bar_back.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_bar_back.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_bar_back.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_bar_back.offset_left = -BAR_SIZE.x / 2.0
	_bar_back.offset_right = BAR_SIZE.x / 2.0
	_bar_back.offset_bottom = -32.0
	_bar_back.offset_top = -32.0 - BAR_SIZE.y
	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(0.78, 0.86, 1.0, 0.9)  # the recognition-tint blue
	_bar_back.add_child(_bar_fill)
	update_state(false, false, 0.0)
	if GameEvents:
		GameEvents.exploration_paused.connect(func() -> void:
			_paused = true
			update_state(false, false, 0.0))
		GameEvents.exploration_resumed.connect(func() -> void:
			_paused = false)


## Pure display rule, unit-tested: near a target and idle -> hint text;
## holding -> progress bar; otherwise nothing.
static func display_state(near: bool, soothing: bool, ratio: float) -> Dictionary:
	if soothing:
		return {"text": "keep holding…", "bar": clampf(ratio, 0.0, 1.0), "visible": true}
	if near:
		return {"text": "HOLD E — sing to it", "bar": -1.0, "visible": true}
	return {"text": "", "bar": -1.0, "visible": false}


func update_state(near: bool, soothing: bool, ratio: float) -> void:
	if _paused:
		near = false
		soothing = false
	var s: Dictionary = display_state(near, soothing, ratio)
	_label.visible = bool(s["visible"])
	_label.text = String(s["text"])
	var bar: float = float(s["bar"])
	_bar_back.visible = bar >= 0.0
	_bar_fill.size = Vector2(BAR_SIZE.x * maxf(bar, 0.0), BAR_SIZE.y)
