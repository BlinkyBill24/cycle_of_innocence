extends CanvasLayer
## On-screen touch controls: virtual stick (left) + attack/interact buttons
## (right). Visible on touch devices, or force_visible for desktop testing.
## The stick feeds the move_* actions with analog strength each frame.

@export var force_visible := false

var _stick: VirtualStick


func _ready() -> void:
	layer = 20
	_build_ui()
	visible = force_visible or DisplayServer.is_touchscreen_available()
	set_process(visible)


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_stick = VirtualStick.new()
	_stick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_stick.position = Vector2(28, -132)
	_stick.size = Vector2(100, 100)
	root.add_child(_stick)

	var attack := TouchActionButton.new()
	attack.action = &"attack"
	attack.label_text = "ATK"
	attack.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	attack.position = Vector2(-96, -110)
	root.add_child(attack)

	var interact := TouchActionButton.new()
	interact.action = &"interact"
	interact.label_text = "E"
	interact.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	interact.position = Vector2(-170, -76)
	root.add_child(interact)


func _process(_delta: float) -> void:
	var out := _stick.get_output() if _stick else Vector2.ZERO
	_feed_axis(&"move_left", -out.x)
	_feed_axis(&"move_right", out.x)
	_feed_axis(&"move_up", -out.y)
	_feed_axis(&"move_down", out.y)


func _feed_axis(action: StringName, value: float) -> void:
	if value > 0.0:
		Input.action_press(action, clampf(value, 0.0, 1.0))
	else:
		Input.action_release(action)
