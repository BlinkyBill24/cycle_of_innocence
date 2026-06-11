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


func test_hit_plays_hurt_animation_then_recovers() -> void:
	var hitbox := Hitbox.new()
	add_child_autofree(hitbox)
	hitbox.global_position = player.global_position + Vector2(10, 0)
	player._on_hit_received(hitbox)
	assert_eq(player.animated_sprite.animation, &"hurt", "hit reaction is visible")
	await wait_seconds(player.HURT_SECONDS + 0.1)
	assert_true(String(player.animated_sprite.animation).begins_with("idle_"),
			"locomotion resumes after the stagger")
