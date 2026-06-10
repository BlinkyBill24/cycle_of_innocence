extends GutTest
## Briar / CompanionBase: HSM wiring, assist gating (bond + fear), dig flow,
## fear reaction to the global dread tier.

var briar: CompanionBase


func before_each() -> void:
	DreadManager.reset()
	PlayerData.reset_to_defaults()  # Briar bond 25
	briar = load("res://scenes/companions/briar.tscn").instantiate()
	add_child_autofree(briar)
	await wait_physics_frames(1)


func after_each() -> void:
	DreadManager.reset()
	PlayerData.reset_to_defaults()


func _make_spot() -> DiggableSpot:
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(5, 0)
	return spot


func test_starts_following() -> void:
	assert_true(briar.hsm.is_active())
	assert_eq(briar.hsm.get_active_state(), briar._state_follow)


func test_dig_accepted_with_bond_and_calm() -> void:
	var spot := _make_spot()
	assert_true(briar.command_dig(spot))
	assert_eq(briar.hsm.get_active_state(), briar._state_dig)


func test_dig_completes_reveals_and_rewards_bond() -> void:
	watch_signals(briar)
	watch_signals(GameEvents)
	var spot := _make_spot()
	var bond_before := briar.get_bond()
	briar.command_dig(spot)
	await wait_seconds(briar.dig_seconds + 0.6)
	assert_true(spot.revealed, "spot revealed after dig completes")
	assert_signal_emitted(briar, "assist_completed")
	assert_signal_emitted_with_parameters(GameEvents, "diggable_revealed", [&"playground_buried_toy"])
	assert_eq(briar.get_bond(), bond_before + briar.dig_bond_reward)
	assert_eq(briar.hsm.get_active_state(), briar._state_follow)


func test_dig_refused_when_afraid() -> void:
	watch_signals(briar)
	DreadManager.add_dread(90.0)
	var spot := _make_spot()
	assert_false(briar.command_dig(spot))
	assert_signal_emitted_with_parameters(briar, "assist_refused", [&"afraid"])


func test_dig_refused_at_low_bond() -> void:
	watch_signals(briar)
	PlayerData.set_companion_bond(&"briar", 0.0)
	var spot := _make_spot()
	assert_false(briar.command_dig(spot))
	assert_signal_emitted_with_parameters(briar, "assist_refused", [&"low_bond"])


func test_high_dread_triggers_cower_and_calming_recovers() -> void:
	DreadManager.add_dread(90.0)
	await wait_physics_frames(2)
	assert_eq(briar.hsm.get_active_state(), briar._state_cower, "terror -> cower")
	DreadManager.reset()
	await wait_physics_frames(2)
	assert_eq(briar.hsm.get_active_state(), briar._state_follow, "calm -> follow again")


func test_spawning_into_terror_starts_cowering() -> void:
	DreadManager.add_dread(90.0)
	var scared: CompanionBase = load("res://scenes/companions/briar.tscn").instantiate()
	add_child_autofree(scared)
	await wait_physics_frames(1)
	assert_eq(scared.hsm.get_active_state(), scared._state_cower, "spawn-time fear check (Codex gate)")


func test_no_bond_reward_when_spot_already_revealed_mid_dig() -> void:
	watch_signals(briar)
	var spot := _make_spot()
	var bond_before := briar.get_bond()
	briar.command_dig(spot)
	spot.reveal()  # something else uncovers it during the dig
	await wait_seconds(briar.dig_seconds + 0.6)
	assert_eq(briar.get_bond(), bond_before, "no reward for a no-op reveal")
	assert_signal_not_emitted(briar, "assist_completed")
	assert_eq(briar.hsm.get_active_state(), briar._state_follow, "still returns to follow")


func test_revealed_spot_cannot_reveal_twice() -> void:
	watch_signals(GameEvents)
	var spot := _make_spot()
	spot.reveal()
	spot.reveal()
	assert_signal_emit_count(GameEvents, "diggable_revealed", 1)
