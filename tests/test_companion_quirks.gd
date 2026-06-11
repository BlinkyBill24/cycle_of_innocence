extends GutTest
## Companion quirks: authored acquisition thresholds, persistence, the
## insight tell rule, and Briar's expression behaviors.

const BRIAR := &"briar"


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	WorldState.reset()
	HollowingClock.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	WorldState.reset()
	HollowingClock.reset()


func test_briar_pool_is_authored_and_fixed() -> void:
	assert_eq(CompanionQuirkDefs.quirks_for(BRIAR).size(), 4,
			"hand-defined pool — never procedural")


func test_bond_threshold_acquires_quirk_once() -> void:
	watch_signals(GameEvents)
	PlayerData.set_companion_bond(BRIAR, 60.0)
	assert_true(PlayerData.has_quirk(BRIAR, &"briar_scent_growl"))
	assert_signal_emitted_with_parameters(GameEvents, "quirk_acquired",
			[BRIAR, &"briar_scent_growl"])
	PlayerData.set_companion_bond(BRIAR, 65.0)
	assert_eq(PlayerData.get_companion_quirks(BRIAR).count(&"briar_scent_growl"), 1,
			"acquired exactly once")


func test_corruption_thresholds_stack() -> void:
	PlayerData.set_companion_corruption(BRIAR, 45.0)
	assert_true(PlayerData.has_quirk(BRIAR, &"briar_long_stare"))
	assert_false(PlayerData.has_quirk(BRIAR, &"briar_phantom_guard"))
	PlayerData.set_companion_corruption(BRIAR, 70.0)
	assert_true(PlayerData.has_quirk(BRIAR, &"briar_phantom_guard"))
	assert_eq(PlayerData.get_companion_quirks(BRIAR).size(), 2)


func test_below_threshold_acquires_nothing() -> void:
	PlayerData.set_companion_bond(BRIAR, 59.0)
	PlayerData.set_companion_corruption(BRIAR, 39.0)
	assert_true(PlayerData.get_companion_quirks(BRIAR).is_empty())


func test_quirks_survive_save_roundtrip() -> void:
	PlayerData.set_companion_corruption(BRIAR, 40.0)
	var data: Dictionary = PlayerData.get_save_data()
	PlayerData.reset_to_defaults()
	PlayerData.apply_save_data(data)
	assert_true(PlayerData.has_quirk(BRIAR, &"briar_long_stare"),
			"quirks are never silently removed — not even by reload")


func test_insight_tell_rule() -> void:
	var innocent: int = PlayerData.MoralityTier.INNOCENT_EMPATH
	var vessel: int = PlayerData.MoralityTier.VESSEL
	assert_true(CompanionBase.insight_tell_visible(true, innocent, 60.0))
	assert_false(CompanionBase.insight_tell_visible(false, innocent, 60.0),
			"a phantom guard never earns the tell — that ambiguity is the horror")
	assert_false(CompanionBase.insight_tell_visible(true, vessel, 100.0),
			"the Vessel sees nothing wrong at all")
	assert_false(CompanionBase.insight_tell_visible(true, innocent, 50.0),
			"insight must be earned")


func _spawn_briar_with_player() -> Array:
	var briar: CompanionBase = load("res://scenes/companions/briar.tscn").instantiate()
	add_child_autofree(briar)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = briar.global_position + Vector2(10, 0)
	return [briar, player]


func test_scent_growl_pings_buried_things() -> void:
	PlayerData.set_companion_bond(BRIAR, 60.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(50, 0)
	watch_signals(GameEvents)
	await wait_physics_frames(3)
	assert_eq(briar.hsm.get_active_state(), briar._state_quirk, "growls at the empty corner")
	assert_signal_emitted_with_parameters(GameEvents, "quirk_expressed",
			[BRIAR, &"briar_scent_growl"])


func test_no_ping_for_revealed_spots() -> void:
	PlayerData.set_companion_bond(BRIAR, 60.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(50, 0)
	spot.reveal()
	await wait_physics_frames(3)
	assert_eq(briar.hsm.get_active_state(), briar._state_follow, "nothing left to point at")


func test_quirks_freeze_during_dialogue() -> void:
	PlayerData.set_companion_bond(BRIAR, 60.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(50, 0)
	GameEvents.exploration_paused.emit()
	await wait_physics_frames(3)
	assert_eq(briar.hsm.get_active_state(), briar._state_follow, "frozen mid-dialogue")
	GameEvents.exploration_resumed.emit()
	await wait_physics_frames(3)
	assert_eq(briar.hsm.get_active_state(), briar._state_quirk)


func test_phantom_guard_growls_at_nothing() -> void:
	PlayerData.set_companion_corruption(BRIAR, 70.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	briar._phantom_timer = 0.0
	watch_signals(GameEvents)
	await wait_physics_frames(3)
	assert_eq(briar.hsm.get_active_state(), briar._state_quirk)
	assert_signal_emitted_with_parameters(GameEvents, "quirk_expressed",
			[BRIAR, &"briar_phantom_guard"])
	assert_false(briar._quirk_truth, "there is nothing there")


func test_long_stare_delays_the_order() -> void:
	PlayerData.set_companion_corruption(BRIAR, 45.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(30, 0)
	assert_true(briar.command_dig(spot))
	assert_gt(briar._stare_timer, 0.0, "a beat too long before complying")


func test_earned_bond_softens_the_stare() -> void:
	PlayerData.set_companion_corruption(BRIAR, 45.0)
	PlayerData.set_companion_bond(BRIAR, 70.0)
	var nodes: Array = _spawn_briar_with_player()
	var briar: CompanionBase = nodes[0]
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = briar.global_position + Vector2(30, 0)
	assert_true(briar.command_dig(spot))
	assert_eq(briar._stare_timer, 0.0, "the stare became a head-bump — visibly changed, not removed")


func test_dusk_press_comforts() -> void:
	PlayerData.set_companion_bond(BRIAR, 75.0)
	var nodes: Array = _spawn_briar_with_player()
	DreadManager.add_dread(40.0)
	watch_signals(GameEvents)
	WorldState.advance_time()  # dusk -> night
	assert_signal_emitted_with_parameters(GameEvents, "quirk_expressed",
			[BRIAR, &"briar_dusk_press"])
	assert_eq(DreadManager.dread, 35.0, "the family holds: -5 dread")
