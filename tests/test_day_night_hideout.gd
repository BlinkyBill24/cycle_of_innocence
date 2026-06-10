extends GutTest
## WorldState clock + night dread floor + hideout rest/play effects.


func before_each() -> void:
	WorldState.reset()
	DreadManager.reset()
	PlayerData.reset_to_defaults()


func after_each() -> void:
	WorldState.reset()
	DreadManager.reset()
	PlayerData.reset_to_defaults()
	SaveManager.delete_save(0)
	AdaptiveAudio.set_hideout(false)


func test_clock_cycles_and_increments_day() -> void:
	watch_signals(WorldState)
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.DUSK, "story starts at dusk")
	WorldState.advance_time()
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.NIGHT)
	WorldState.advance_time()
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.DAWN)
	assert_eq(WorldState.day, 2, "dawn after night = new day")
	assert_signal_emit_count(WorldState, "time_changed", 2)


func test_night_raises_dread_floor() -> void:
	WorldState.advance_time()  # dusk -> night
	assert_eq(DreadManager.get_zone_baseline(), 20.0, "night floor active")
	WorldState.advance_time()  # night -> dawn
	assert_eq(DreadManager.get_zone_baseline(), 0.0, "floor lifts at dawn")


func test_sleep_to_dawn_advances_day() -> void:
	WorldState.advance_time()  # night
	WorldState.sleep_to_dawn()
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.DAWN)
	assert_eq(WorldState.day, 2)


func test_world_time_survives_save_load() -> void:
	WorldState.advance_time()  # night, day 1
	SaveManager.save_game(0)
	WorldState.reset()
	assert_true(SaveManager.load_game(0))
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.NIGHT)


func test_hideout_rest_heals_saves_and_cares() -> void:
	var hideout: Hideout = load("res://scripts/world/hideout.gd").new()
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	hideout.add_child(shape)
	add_child_autofree(hideout)
	var player: PlayerController = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	player.global_position = hideout.global_position
	await wait_physics_frames(3)
	assert_true(hideout.player_inside, "player detected in camp")

	player.health.take_damage(6)
	DreadManager.add_dread(50.0)
	WorldState.advance_time()  # night
	var bond_before: float = PlayerData.get_companion(&"briar").bond
	assert_true(hideout.try_interact(player))
	await wait_seconds(1.2)
	assert_eq(WorldState.time_of_day, WorldState.TimeOfDay.DAWN, "slept to dawn")
	assert_eq(player.health.hp, player.health.max_hp, "rested = healed")
	assert_eq(DreadManager.dread, 0.0, "rested = dread relieved")
	assert_gt(PlayerData.get_companion(&"briar").bond, bond_before, "care moment")
	assert_true(SaveManager.has_save(0), "rest saves the game")


func test_hideout_audio_override_selects_warm_layer() -> void:
	var audio: Node = load("res://scripts/autoload/adaptive_audio.gd").new()
	add_child_autofree(audio)
	audio.set_process(false)
	audio.set_hideout(true)
	audio._process(0.1)
	assert_eq(audio._active, audio.Layer.HIDEOUT, "warm stem takes the channel")
	audio.set_hideout(false)
	audio._process(0.1)
	assert_ne(audio._active, audio.Layer.HIDEOUT, "returns to dread-driven selection")
