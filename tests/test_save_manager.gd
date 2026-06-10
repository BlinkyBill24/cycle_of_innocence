extends GutTest
## SaveManager round-trip + PlayerData story flags / serialization.

const SLOT := 9  # test slot, never user slot 0


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func after_each() -> void:
	SaveManager.delete_save(SLOT)
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	ZoneManager.current_zone_id = &""


func test_story_flags_set_has_and_reset() -> void:
	assert_false(PlayerData.has_story_flag(&"food_shared"))
	PlayerData.set_story_flag(&"food_shared")
	PlayerData.set_story_flag(&"food_shared")
	assert_true(PlayerData.has_story_flag(&"food_shared"))
	assert_eq(PlayerData.story_flags.size(), 1, "no duplicates")
	PlayerData.reset_to_defaults()
	assert_false(PlayerData.has_story_flag(&"food_shared"))


func test_bond_delta_helpers() -> void:
	PlayerData.add_companion_bond(&"briar", 10.0)
	assert_eq(PlayerData.get_companion(&"briar").bond, 35.0)
	PlayerData.add_companion_corruption(&"briar", 15.0)
	assert_eq(PlayerData.get_companion(&"briar").corruption, 15.0)


func test_save_load_round_trip() -> void:
	PlayerData.change_morality(-25.0)
	PlayerData.set_age_stage(PlayerData.AgeStage.TEEN)
	PlayerData.add_companion_bond(&"briar", 20.0)
	PlayerData.unlock_revelation(&"monsters_are_children")
	PlayerData.set_story_flag(&"food_shared")
	PlayerData.custom_name = "Ash"
	DreadManager.add_dread(33.0)
	ZoneManager.enter_zone(&"playground_fringes")
	# revelation unlock above also spiked dread (+15, by design) — capture actual
	var dread_at_save := DreadManager.dread

	assert_true(SaveManager.save_game(SLOT))
	assert_true(SaveManager.has_save(SLOT))

	PlayerData.reset_to_defaults()
	DreadManager.reset()
	ZoneManager.current_zone_id = &""

	assert_true(SaveManager.load_game(SLOT, false))
	assert_eq(PlayerData.morality, -25.0)
	assert_eq(PlayerData.age_stage, PlayerData.AgeStage.TEEN)
	assert_eq(PlayerData.get_companion(&"briar").bond, 45.0)
	assert_true(PlayerData.is_revelation_known(&"monsters_are_children"))
	assert_true(PlayerData.has_story_flag(&"food_shared"))
	assert_eq(PlayerData.custom_name, "Ash")
	assert_eq(DreadManager.dread, dread_at_save)
	assert_eq(ZoneManager.current_zone_id, &"playground_fringes")


func test_load_emits_resync_signals() -> void:
	PlayerData.change_morality(40.0)
	SaveManager.save_game(SLOT)
	PlayerData.reset_to_defaults()
	watch_signals(PlayerData)
	SaveManager.load_game(SLOT, false)
	assert_signal_emitted(PlayerData, "morality_changed")
	assert_signal_emitted(PlayerData, "age_advanced")


func test_load_missing_slot_returns_false() -> void:
	assert_false(SaveManager.load_game(8, false))


func test_food_dialogue_resource_compiles() -> void:
	var res: DialogueResource = load("res://resources/dialogue/escape_food.dialogue")
	assert_not_null(res)
	assert_true(res.get_titles().has("start"), "start title present")
