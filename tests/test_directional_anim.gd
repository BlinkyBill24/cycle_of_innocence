extends GutTest
## Directional animation selection: true 4-direction rows (PixelLab batch),
## no mirroring (the flip-era moonwalk fix is superseded by real west frames).


func test_right_and_left_use_their_own_rows() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2.RIGHT), ["walk_right", false])
	assert_eq(PlayerController.directional_anim("walk", Vector2.LEFT), ["walk_left", false])


func test_vertical() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2.DOWN), ["walk_down", false])
	assert_eq(PlayerController.directional_anim("idle", Vector2.UP), ["idle_up", false])


func test_diagonal_prefers_dominant_axis() -> void:
	assert_eq(PlayerController.directional_anim("walk", Vector2(-0.9, 0.3).normalized()), ["walk_left", false])
	assert_eq(PlayerController.directional_anim("walk", Vector2(0.2, 0.9).normalized()), ["walk_down", false])
