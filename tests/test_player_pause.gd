extends GutTest
## Modal pause: while the satchel / dialogue / name-entry own the world
## (GameEvents.exploration_paused), Rowan must hold still and read no movement —
## arrow keys are also bound to ui_left/right for menu nav, so without this the
## character walked while the player only meant to select an item (playtest 2026-06-20).

var player: PlayerController


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	await wait_physics_frames(1)


func after_each() -> void:
	GameEvents.exploration_resumed.emit()  # never leave the world paused for the next test
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func test_exploration_paused_sets_the_freeze_flag() -> void:
	assert_false(player._paused, "live by default")
	GameEvents.exploration_paused.emit()
	assert_true(player._paused, "a modal freezes Rowan")
	GameEvents.exploration_resumed.emit()
	assert_false(player._paused, "and resuming thaws him")


func test_paused_player_holds_still_even_with_velocity() -> void:
	GameEvents.exploration_paused.emit()
	player.global_position = Vector2.ZERO
	player.velocity = Vector2(160, 0)  # pretend he was mid-run when the satchel opened
	await wait_physics_frames(2)
	assert_eq(player.velocity, Vector2.ZERO, "paused player is forced to a stop")
	assert_almost_eq(player.global_position.x, 0.0, 0.5, "and does not drift while paused")


func test_resumed_player_is_live_again() -> void:
	GameEvents.exploration_paused.emit()
	GameEvents.exploration_resumed.emit()
	assert_false(player._paused)
	assert_eq(player.movement_state, PlayerController.MovementState.EXPLORING,
		"control returns to normal exploration")
