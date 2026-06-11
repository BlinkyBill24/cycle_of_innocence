extends GutTest
## Interface horror (interface-horror.md): the pressure rule, control
## degradation spikes (presentation only, accessibility-gated), and the
## Vessel dialogue distortion — the game stops obeying you, fairly.

var player: PlayerController


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	DreadManager.set_horror_intensity(1.0)
	player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	await wait_physics_frames(1)


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	DreadManager.set_horror_intensity(1.0)


# --- pressure rule ---

func test_pressure_hard_off_below_intensity_gate() -> void:
	assert_eq(DreadManager.interface_pressure_rule(100.0, 100.0, 0.39), 0.0,
			"accessibility contract: below 40% intensity nothing degrades")


func test_pressure_ramps_in_the_terror_band() -> void:
	assert_eq(DreadManager.interface_pressure_rule(85.0, 0.0, 1.0), 0.0)
	assert_almost_eq(DreadManager.interface_pressure_rule(92.5, 0.0, 1.0), 0.5, 0.01)
	assert_almost_eq(DreadManager.interface_pressure_rule(100.0, 0.0, 1.0), 1.0, 0.001)


func test_pressure_ramps_toward_vessel() -> void:
	assert_eq(DreadManager.interface_pressure_rule(0.0, 70.0, 1.0), 0.0)
	assert_almost_eq(DreadManager.interface_pressure_rule(0.0, 100.0, 1.0), 1.0, 0.001)


func test_pressure_scales_with_intensity() -> void:
	assert_almost_eq(DreadManager.interface_pressure_rule(100.0, 0.0, 0.5), 0.5, 0.001)


# --- control degradation spikes ---

func test_spike_lags_input_then_releases_fifo() -> void:
	player.start_interface_spike(1.0)
	assert_eq(player._spike_lag_frames, 3, "full pressure = 3-frame pulse")
	assert_eq(player._lagged_input(Vector2.RIGHT), Vector2.ZERO)
	assert_eq(player._lagged_input(Vector2.RIGHT), Vector2.ZERO)
	assert_eq(player._lagged_input(Vector2.RIGHT), Vector2.ZERO)
	assert_eq(player._lagged_input(Vector2.RIGHT), Vector2.RIGHT, "then input flows, delayed")


func test_spike_eats_exactly_one_attack_press() -> void:
	player.start_interface_spike(1.0)
	assert_true(player._spike_eats_press(), "the hand hesitates once")
	assert_false(player._spike_eats_press(), "never twice per spike")


func test_no_press_eaten_outside_a_spike() -> void:
	assert_false(player._spike_eats_press())


func test_spike_hitches_then_restores_walk_speed() -> void:
	var base: float = player.animated_sprite.speed_scale
	player.start_interface_spike(1.0)
	assert_almost_eq(player.animated_sprite.speed_scale,
			base * player.SPIKE_HITCH_FACTOR, 0.001)
	player._end_spike()
	assert_almost_eq(player.animated_sprite.speed_scale, base, 0.001)


func test_spike_duration_never_exceeds_two_seconds() -> void:
	player.start_interface_spike(99.0)
	assert_lte(player._spike_timer, player.SPIKE_MAX_SECONDS)


# --- dialogue distortion ---

func _line_after_first_response(morality: float) -> DialogueLine:
	PlayerData.change_morality(morality)
	var resource: DialogueResource = load("res://resources/dialogue/escape_food.dialogue")
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	var guard := 0
	while line.responses.is_empty() and guard < 10:
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id)
		guard += 1
	return await DialogueManager.get_next_dialogue_line(resource, line.responses[0].next_id)


func test_vessel_tier_distorts_the_spoken_line() -> void:
	# morality 100; the choice's own -10 mutation runs first -> 90, still Vessel
	var line: DialogueLine = await _line_after_first_response(100.0)
	assert_string_contains(line.text, "while it is offered", "the Vessel's grammar")
	assert_string_contains(line.text, "[shake", "distortion always visibly marked")


func test_innocent_speaks_their_own_words() -> void:
	var line: DialogueLine = await _line_after_first_response(0.0)
	assert_string_contains(line.text, "Half for you", "no distortion below Vessel")
