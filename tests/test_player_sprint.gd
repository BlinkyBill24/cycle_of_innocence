extends GutTest
## Sprint: hold to run in short bursts from an invisible reserve; spending it forces a
## recovery (drop to walk) until it refills. No stamina bar. The run "look" is the walk
## animation played faster (speed_scale), composed with age + dread-spike factors.

var player: PlayerController

const MAX := PlayerController.SPRINT_MAX_SECONDS
const ANIM := PlayerController.SPRINT_ANIM_SCALE
const HITCH := PlayerController.SPIKE_HITCH_FACTOR


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	await wait_physics_frames(1)


func after_each() -> void:
	Input.action_release(&"sprint")
	PlayerData.reset_to_defaults()
	DreadManager.reset()


# --- pure reserve transition (no node) ---

func test_step_drains_and_sprints_while_wanted() -> void:
	var r := PlayerController.sprint_step(MAX, false, true, 0.1)
	assert_true(r["sprinting"], "wanting + reserve -> sprinting")
	assert_almost_eq(float(r["charge"]), MAX - 0.1, 0.0001, "reserve drains by delta")
	assert_false(r["locked"], "not locked until empty")


func test_step_locks_when_reserve_empties() -> void:
	var r := PlayerController.sprint_step(0.05, false, true, 0.1)
	assert_eq(float(r["charge"]), 0.0, "reserve clamps at 0")
	assert_true(r["locked"], "empties -> forced recovery")
	assert_false(r["sprinting"] and r["locked"] == false, "no sprint past empty")


func test_step_stays_locked_until_full_then_releases() -> void:
	# still recovering: wants is ignored while locked
	var mid := PlayerController.sprint_step(0.4, true, true, 0.1)
	assert_true(mid["locked"], "still locked below full")
	assert_false(mid["sprinting"], "cannot sprint during recovery")
	# enough regen to reach full -> unlocks
	var done := PlayerController.sprint_step(MAX - 0.01, true, true, 0.1)
	assert_false(done["locked"], "refilled to full -> sprint allowed again")


func test_step_recharges_when_idle() -> void:
	var r := PlayerController.sprint_step(1.0, false, false, 0.1)
	assert_almost_eq(float(r["charge"]), 1.0 + 0.5 * 0.1, 0.0001, "regens when not sprinting")
	assert_false(r["sprinting"])


# --- integration: speed + animation composition ---

func test_run_speed_faster_than_walk() -> void:
	assert_gt(player.run_speed, player.move_speed, "run is faster than walk")


func test_sprint_speeds_up_the_walk_animation() -> void:
	player._set_sprinting(true)
	assert_almost_eq(player.animated_sprite.speed_scale, ANIM, 0.001,
		"child sprint = 1.0 * 1.5")
	player._set_sprinting(false)
	assert_almost_eq(player.animated_sprite.speed_scale, 1.0, 0.001, "back to base")


func test_sprint_composes_with_dread_spike() -> void:
	player._set_sprinting(true)
	player.start_interface_spike(1.0)
	assert_almost_eq(player.animated_sprite.speed_scale, ANIM * HITCH, 0.001,
		"sprint × spike multiply (1.5 × 0.8)")
	player._end_spike()
	assert_almost_eq(player.animated_sprite.speed_scale, ANIM, 0.001,
		"spike ends, sprint survives")


func test_sprint_composes_with_age() -> void:
	player.age_morph.age_speed_factor = 0.9  # ADULT gait
	player._set_sprinting(true)
	assert_almost_eq(player.animated_sprite.speed_scale, 0.9 * ANIM, 0.001,
		"adult sprint = 0.9 × 1.5")


func test_leaving_exploring_clears_sprint() -> void:
	player._set_sprinting(true)
	player.set_movement_state(PlayerController.MovementState.HURT)
	await wait_physics_frames(1)
	assert_false(player._is_sprinting, "sprint cleared outside EXPLORING")
	assert_almost_eq(player.animated_sprite.speed_scale, 1.0, 0.001, "gait back to base")


func test_holding_sprint_while_idle_neither_drains_nor_sprints() -> void:
	Input.action_press(&"sprint")
	player._update_sprint(0.1, Vector2.ZERO)  # held but no movement input
	assert_false(player._is_sprinting, "no sprint without movement")
	assert_almost_eq(player._sprint_charge, MAX, 0.0001, "reserve untouched while idle")
	Input.action_release(&"sprint")


func test_holding_past_burst_forces_recovery_lockout() -> void:
	Input.action_press(&"sprint")
	player._update_sprint(MAX + 0.5, Vector2.RIGHT)  # exhaust in one big step
	assert_true(player._sprint_locked, "burst spent -> locked")
	player._update_sprint(0.016, Vector2.RIGHT)      # still holding
	assert_false(player._is_sprinting, "cannot re-sprint during recovery")
	Input.action_release(&"sprint")
