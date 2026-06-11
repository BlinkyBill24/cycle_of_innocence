extends GutTest
## Post-cutscene input grace: the Space press that closes a dialogue balloon
## must not leak into an attack the frame control returns (playtest 2026-06-11).

var player: PlayerController


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	await wait_physics_frames(1)


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func test_leaving_cutscene_arms_input_grace() -> void:
	player.set_movement_state(PlayerController.MovementState.CUTSCENE)
	player.set_movement_state(PlayerController.MovementState.EXPLORING)
	assert_gt(player._input_grace, 0.0, "grace window armed")


func test_grace_expires_after_window() -> void:
	player.set_movement_state(PlayerController.MovementState.CUTSCENE)
	player.set_movement_state(PlayerController.MovementState.EXPLORING)
	await wait_seconds(PlayerController.POST_CUTSCENE_INPUT_GRACE + 0.1)
	assert_eq(player._input_grace, 0.0, "grace decays back to live input")


func test_attack_recovery_does_not_arm_grace() -> void:
	player.set_movement_state(PlayerController.MovementState.ATTACKING)
	player.set_movement_state(PlayerController.MovementState.EXPLORING)
	assert_eq(player._input_grace, 0.0, "combat flow stays responsive")
