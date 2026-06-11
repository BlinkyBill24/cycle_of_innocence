extends GutTest
## NameEntry: normalization, default fallback, the player_named flag, and
## save round-trip of custom_name (playtest feature 2026-06-11).


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()


func test_apply_name_sets_custom_name_and_flag() -> void:
	assert_eq(NameEntry.apply_name("Ash"), "Ash")
	assert_eq(PlayerData.custom_name, "Ash")
	assert_true(PlayerData.has_story_flag(&"player_named"))


func test_apply_name_trims_whitespace() -> void:
	assert_eq(NameEntry.apply_name("  Wren  "), "Wren")
	assert_eq(PlayerData.custom_name, "Wren")


func test_empty_name_falls_back_to_default() -> void:
	assert_eq(NameEntry.apply_name("   "), "Rowan")
	assert_eq(PlayerData.custom_name, "Rowan")
	assert_true(PlayerData.has_story_flag(&"player_named"), "still counts as named")


func test_overlong_name_is_clamped() -> void:
	var chosen := NameEntry.apply_name("Bartholomewvonplaygroundia")
	assert_eq(chosen.length(), NameEntry.MAX_NAME_LENGTH)


func test_custom_name_survives_save_round_trip() -> void:
	NameEntry.apply_name("Juniper")
	var data := PlayerData.get_save_data()
	PlayerData.reset_to_defaults()
	PlayerData.apply_save_data(data)
	assert_eq(PlayerData.custom_name, "Juniper")
	assert_true(PlayerData.has_story_flag(&"player_named"), "never asks twice")


func test_intro_dialogue_speaks_the_chosen_name() -> void:
	NameEntry.apply_name("Ash")
	var resource: DialogueResource = load("res://resources/dialogue/escape_food.dialogue")
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, "start")
	assert_eq(line.character, "Ash", "speaker label uses the chosen name")


func test_skips_itself_when_already_named() -> void:
	PlayerData.set_story_flag(&"player_named")
	var entry: NameEntry = load("res://scripts/ui/name_entry.gd").new()
	add_child_autofree(entry)
	await wait_physics_frames(2)
	assert_false(is_instance_valid(entry), "prompt frees itself on reload")
