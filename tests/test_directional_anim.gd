extends GutTest
## Moonwalk regression: side animations use the right-facing row + flip_h.


func test_right_uses_right_row_unflipped() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2.RIGHT), ["walk_right", false])


func test_left_uses_right_row_flipped() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2.LEFT), ["walk_right", true])


func test_vertical_unflipped() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2.DOWN), ["walk_down", false])
	assert_eq(PlayerController.directional_anim("idle", Vector2.UP), ["idle_up", false])


func test_diagonal_prefers_dominant_axis() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2(-0.9, 0.3).normalized()), ["walk_right", true])
	assert_eq(PlayerController.directional_anim("walk", Vector2(0.2, 0.9).normalized()), ["walk_down", false])
