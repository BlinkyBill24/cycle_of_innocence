extends GutTest
## Project-owned compact balloon (scenes/ui/dialogue_balloon.tscn): the scene
## is hand-authored, so smoke-test its wiring — and verify end-to-end that the
## speaker label shows the chosen player name (playtest 2026-06-11: ROWAN).


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()


func test_balloon_scene_instantiates_with_wiring() -> void:
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	assert_not_null(balloon.dialogue_label, "dialogue label wired")
	assert_not_null(balloon.character_label, "character label wired")
	assert_not_null(balloon.responses_menu, "responses menu wired")


func test_balloon_speaker_label_shows_chosen_name() -> void:
	NameEntry.apply_name("Vesper")
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	balloon.start(load("res://resources/dialogue/escape_food.dialogue"), "start")
	await wait_seconds(0.4)
	assert_eq(balloon.character_label.text, "Vesper", "the box speaks the chosen name")
