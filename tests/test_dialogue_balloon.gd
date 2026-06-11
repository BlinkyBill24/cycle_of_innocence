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


func test_choices_live_inside_the_box() -> void:
	# FF7-style (playtest 2026-06-11): the responses menu is a child of the
	# panel's text column, not a floating overlay
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	var menu: Node = balloon.responses_menu
	var panel := balloon.get_node("Balloon/BalloonMargin/PanelContainer")
	assert_true(panel.is_ancestor_of(menu), "responses render inside the panel")


func test_box_grows_for_choices_and_shrinks_back() -> void:
	NameEntry.apply_name("Quinn")
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	balloon.start(load("res://resources/dialogue/escape_food.dialogue"), "start")
	await wait_seconds(0.4)
	assert_eq(balloon.balloon_margin.offset_top, balloon.BOX_TOP_PLAIN,
			"plain line: compact box")
	# walk to the choice line (4 plain lines precede the responses)
	for i in range(3):
		balloon.next(balloon.dialogue_line.next_id)
		await wait_seconds(0.35)
	assert_gt(balloon.dialogue_line.responses.size(), 0, "reached the choice")
	assert_eq(balloon.balloon_margin.offset_top, balloon.BOX_TOP_CHOICES,
			"choices: the box grows")


func test_balloon_speaker_label_shows_chosen_name() -> void:
	NameEntry.apply_name("Vesper")
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	balloon.start(load("res://resources/dialogue/escape_food.dialogue"), "start")
	await wait_seconds(0.4)
	assert_eq(balloon.character_label.text, "Vesper", "the box speaks the chosen name")


func test_response_selection_is_wired_and_advances_the_story() -> void:
	# regression (playtest 2026-06-11): the scene-surgery that moved the
	# menu inside the box left the response_selected [connection] pointing
	# at the old node path — choices fired into the void
	var balloon: GameDialogueBalloon = load("res://scenes/ui/dialogue_balloon.tscn").instantiate()
	add_child_autofree(balloon)
	await wait_physics_frames(1)
	assert_true(balloon.responses_menu.response_selected.is_connected(
			balloon._on_responses_menu_response_selected),
			"menu selection reaches the balloon")
	balloon.start(load("res://resources/dialogue/escape_food.dialogue"), "start")
	await wait_seconds(0.3)
	var guard := 0
	while balloon.dialogue_line.responses.is_empty() and guard < 10:
		balloon.dialogue_label.skip_typing()
		await wait_seconds(0.2)
		balloon.next(balloon.dialogue_line.next_id)
		await wait_seconds(0.3)
		guard += 1
	assert_gt(balloon.dialogue_line.responses.size(), 0, "reached the choice")
	var response: DialogueResponse = balloon.dialogue_line.responses[0]
	balloon._on_responses_menu_response_selected(response)
	await wait_seconds(0.4)
	assert_true(PlayerData.has_story_flag(&"food_shared"),
			"selecting a choice actually advances the story")
