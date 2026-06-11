extends GutTest
## Hollowing Clock: milestones, alarm noise, queue rule, Frenzy mercy-undo,
## night-floor scaling, persistence.


func before_each() -> void:
	HollowingClock.reset()
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	WorldState.reset()


func after_each() -> void:
	HollowingClock.reset()
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	WorldState.reset()


func test_starts_at_the_quiet() -> void:
	assert_eq(HollowingClock.stage, HollowingClock.Stage.QUIET,
			"post-escape: safest the game will ever be")


func test_milestone_advances_once_per_id() -> void:
	watch_signals(GameEvents)
	assert_true(HollowingClock.register_milestone(&"m1"))
	assert_false(HollowingClock.register_milestone(&"m1"), "same milestone never double-fires")
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT)
	assert_signal_emitted_with_parameters(GameEvents, "hollowing_stage_advanced", [1])


func test_noise_pulls_the_next_stage_early() -> void:
	HollowingClock.add_alarm(60.0)
	assert_eq(HollowingClock.stage, HollowingClock.Stage.QUIET)
	HollowingClock.add_alarm(50.0)
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT)
	assert_eq(HollowingClock.alarm_points, 10.0, "overflow carries")


func test_mercy_subtracts_noise() -> void:
	HollowingClock.add_alarm(50.0)
	GameEvents.monster_stilled.emit(&"x")
	assert_eq(HollowingClock.alarm_points, 30.0, "stilling quiets the alarm")


func test_kills_betrayal_domination_are_noise() -> void:
	GameEvents.enemy_died.emit(&"x")
	assert_eq(HollowingClock.alarm_points, 25.0)
	GameEvents.monster_dominated.emit(&"x")
	assert_eq(HollowingClock.alarm_points, 60.0)
	GameEvents.stilled_monster_killed.emit(&"x")
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT, "betrayal tipped it")


func test_never_advances_mid_dialogue() -> void:
	GameEvents.exploration_paused.emit()
	HollowingClock.register_milestone(&"m1")
	assert_eq(HollowingClock.stage, HollowingClock.Stage.QUIET, "queued, not fired")
	GameEvents.exploration_resumed.emit()
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT, "fires on resume")


func test_never_advances_inside_the_hideout() -> void:
	GameEvents.hideout_entered.emit()
	HollowingClock.add_alarm(100.0)
	assert_eq(HollowingClock.stage, HollowingClock.Stage.QUIET, "care scenes are safe")
	GameEvents.hideout_exited.emit()
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT)


func test_clamps_at_the_hollowing() -> void:
	for i in 7:
		HollowingClock.register_milestone(StringName("m%d" % i))
	assert_eq(HollowingClock.stage, HollowingClock.STAGE_MAX)


func test_frenzy_undoes_mercy() -> void:
	var enemy: EnemyBase = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)
	enemy.add_recognition(100.0, true)
	assert_true(enemy.stilled)
	var morality_after_spare := PlayerData.morality
	for i in 3:
		HollowingClock.register_milestone(StringName("m%d" % i))
	assert_eq(HollowingClock.stage, HollowingClock.Stage.FRENZY)
	assert_false(enemy.stilled, "the Hunger reasserts its grip")
	assert_eq(enemy.recognition, 0.0, "the calm is gone")
	assert_false(PlayerData.has_story_flag(&"stilled_twisted_child_01"))
	assert_true(PlayerData.has_story_flag(&"spared_twisted_child_01"), "history is kept")
	assert_eq(enemy.hsm.get_active_state(), enemy._state_patrol)
	assert_eq(PlayerData.morality, morality_after_spare, "not the player's blow — no betrayal cost")


func test_frenzy_spawn_ignores_stale_stilled_flag() -> void:
	PlayerData.set_story_flag(&"stilled_twisted_child_01")
	for i in 3:
		HollowingClock.register_milestone(StringName("m%d" % i))
	var enemy: EnemyBase = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)
	assert_false(enemy.stilled, "Frenzy world: nothing stays calm")
	assert_false(PlayerData.has_story_flag(&"stilled_twisted_child_01"))


func test_night_floor_scales_with_stage() -> void:
	HollowingClock.register_milestone(&"m1")  # stage 1
	WorldState.advance_time()  # dusk -> night
	assert_eq(DreadManager.get_zone_baseline(), 25.0, "20 base + 5 per stage")


func test_save_roundtrip() -> void:
	HollowingClock.register_milestone(&"m1")
	HollowingClock.add_alarm(40.0)
	var data: Dictionary = HollowingClock.get_save_data()
	HollowingClock.reset()
	HollowingClock.apply_save_data(data)
	assert_eq(HollowingClock.stage, HollowingClock.Stage.DOUBT)
	assert_eq(HollowingClock.alarm_points, 40.0)
	assert_false(HollowingClock.register_milestone(&"m1"), "consumed milestones persist")
