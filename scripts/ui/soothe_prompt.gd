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
	# explicit anchors only — a preset/grow combo once left the label with a
	# degenerate rect that rendered at the top-left under the HP hearts
	# (playtest tester-02). Bottom-center strip: hearts are top-left, debug
	# top-right, touch buttons bottom corners, so this band stays free.
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 3)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_label)
	_label.anchor_left = 0.0
	_label.anchor_right = 1.0
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = 0.0
	_label.offset_right = 0.0
	_label.offset_top = -64.0
	_label.offset_bottom = -46.0
	_bar_back = ColorRect.new()
	_bar_back.color = Color(0, 0, 0, 0.55)
	add_child(_bar_back)
	_bar_back.anchor_left = 0.5
	_bar_back.anchor_right = 0.5
	_bar_back.anchor_top = 1.0
	_bar_back.anchor_bottom = 1.0
	_bar_back.offset_left = -BAR_SIZE.x / 2.0
	_bar_back.offset_right = BAR_SIZE.x / 2.0
	_bar_back.offset_top = -42.0 - BAR_SIZE.y
	_bar_back.offset_bottom = -42.0
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


## Pure display rule, unit-tested: near a spareable target and idle -> hint;
## holding -> progress bar; keyless plateau -> discovery cue (tester-04);
## near an UNSPAREABLE monster (the emergency-ritual child) -> the horror beat
## made legible (playtest 2026-06-13: "the second one always attacks" read as
## a broken soothe — it is the cost of delay, unsaveable by design); else none.
static func display_state(near: bool, soothing: bool, ratio: float,
		stalled: bool = false, too_far_gone: bool = false) -> Dictionary:
	if soothing and stalled:
		return {"text": "it calms… but something is missing",
				"bar": clampf(ratio, 0.0, 1.0), "visible": true, "stalled": true}
	if soothing:
		return {"text": "keep holding…", "bar": clampf(ratio, 0.0, 1.0),
				"visible": true, "stalled": false}
	if near:
		return {"text": "HOLD E — sing to it", "bar": -1.0, "visible": true,
				"stalled": false}
	if too_far_gone:
		return {"text": "it is too far gone to hear you", "bar": -1.0,
				"visible": true, "stalled": true}  # amber, no bar — cannot be soothed
	return {"text": "", "bar": -1.0, "visible": false, "stalled": false}


func update_state(near: bool, soothing: bool, ratio: float,
		stalled: bool = false, too_far_gone: bool = false) -> void:
	if _paused:
		near = false
		soothing = false
		too_far_gone = false
	var s: Dictionary = display_state(near, soothing, ratio, stalled, too_far_gone)
	_label.visible = bool(s["visible"])
	_label.text = String(s["text"])
	var bar: float = float(s["bar"])
	_bar_back.visible = bar >= 0.0
	_bar_fill.size = Vector2(BAR_SIZE.x * maxf(bar, 0.0), BAR_SIZE.y)
	# amber when the generic lullaby maxes out OR the monster can't be soothed
	_bar_fill.color = Color(0.95, 0.78, 0.4, 0.9) if bool(s["stalled"]) \
			else Color(0.78, 0.86, 1.0, 0.9)
