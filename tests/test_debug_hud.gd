extends GutTest
## Debug HUD placement: the progression-test readout must live on a
## CanvasLayer above the dialogue balloon (layer 100) and anchor to the
## top-right of the SCREEN — as a world-space label it scrolled away with
## the camera (user report 2026-06-12).

const PT := preload("res://scripts/debug/progression_test.gd")


func test_debug_label_is_screen_anchored_top_right() -> void:
	var debug: Node2D = PT.new()
	add_child_autofree(debug)
	var overlay := debug.get_node("DebugOverlay") as CanvasLayer
	assert_not_null(overlay, "readout sits on a CanvasLayer, not in the world")
	assert_gt(overlay.layer, 100, "above the dialogue balloon layer")
	var label := overlay.get_child(0) as Label
	assert_not_null(label)
	assert_eq(label.anchor_left, 1.0, "anchored to the right edge")
	assert_eq(label.anchor_right, 1.0, "anchored to the right edge")
	assert_eq(label.anchor_top, 0.0, "anchored to the top edge")
	assert_eq(label.grow_horizontal, Control.GROW_DIRECTION_BEGIN,
		"grows leftward from the right edge")
	assert_lt(int(label.get_theme_font_size("font_size")), 11,
		"smaller font than the old in-world label")


func test_debug_label_can_be_disabled() -> void:
	var debug: Node2D = PT.new()
	debug.show_debug_label = false
	add_child_autofree(debug)
	assert_null(debug.get_node_or_null("DebugOverlay"))
