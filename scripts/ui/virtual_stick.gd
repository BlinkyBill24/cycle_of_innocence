class_name VirtualStick
extends Control
## On-screen virtual joystick (ported from the godot/ sibling prototype).
## Self-drawing — no textures. Output read by TouchControls each frame.

const DEAD_ZONE := 0.15
const BASE_RADIUS := 50.0
const KNOB_RADIUS := 20.0
const BASE_COLOR := Color(1, 1, 1, 0.15)
const KNOB_COLOR := Color(1, 1, 1, 0.5)

var _touch_index := -1
var _output := Vector2.ZERO
var _knob_offset := Vector2.ZERO


func get_output() -> Vector2:
	return _output


func _ready() -> void:
	custom_minimum_size = Vector2(BASE_RADIUS * 2, BASE_RADIUS * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, BASE_RADIUS, BASE_COLOR)
	draw_arc(center, BASE_RADIUS, 0, TAU, 32, Color(1, 1, 1, 0.3), 2.0)
	draw_circle(center + _knob_offset, KNOB_RADIUS, KNOB_COLOR)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index == -1:
			_touch_index = touch.index
			_update_stick(touch.position)
			accept_event()
		elif not touch.pressed and touch.index == _touch_index:
			_reset()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_index:
			_update_stick(drag.position)
			accept_event()


func _update_stick(touch_pos: Vector2) -> void:
	var center := size * 0.5
	var diff := touch_pos - center
	if diff.length() > BASE_RADIUS:
		diff = diff.normalized() * BASE_RADIUS
	_knob_offset = diff
	var normalized := diff / BASE_RADIUS
	_output = normalized if normalized.length() >= DEAD_ZONE else Vector2.ZERO
	queue_redraw()


func _reset() -> void:
	_touch_index = -1
	_output = Vector2.ZERO
	_knob_offset = Vector2.ZERO
	queue_redraw()
