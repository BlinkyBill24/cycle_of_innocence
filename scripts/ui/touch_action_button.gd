class_name TouchActionButton
extends Control
## On-screen touch button injecting an Input action (ported from godot/ sibling).

var action: StringName = &"attack"
var label_text := "?"
var button_radius := 30.0

var _touch_index := -1
var _pressed := false


func _ready() -> void:
	custom_minimum_size = Vector2(button_radius * 2, button_radius * 2)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, button_radius, Color(1, 1, 1, 0.35 if _pressed else 0.15))
	draw_arc(center, button_radius, 0, TAU, 32, Color(1, 1, 1, 0.4), 2.0)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	draw_string(font, center - text_size * 0.5 + Vector2(0, text_size.y * 0.75),
		label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 0.8))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index == -1:
			_touch_index = touch.index
			_set_pressed(true)
			accept_event()
		elif not touch.pressed and touch.index == _touch_index:
			_touch_index = -1
			_set_pressed(false)
			accept_event()


func _set_pressed(pressed: bool) -> void:
	_pressed = pressed
	if pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)
	queue_redraw()
