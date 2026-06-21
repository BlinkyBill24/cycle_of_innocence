extends GutTest
## Dig reliability (playtest 2026-06-21): when Briar REFUSES (afraid / busy / low bond),
## Rowan must still uncover a dig spot by hand. Previously the hand-dig fallback only ran
## when there was NO companion at all, so in the dread-heavy Hollow House the buried key
## "didn't work" until a re-enter happened to catch Briar calm and in follow.

const DiggableScene := preload("res://scenes/world/diggable_spot.tscn")


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func _player() -> PlayerController:
	var p: PlayerController = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(p)
	p.global_position = Vector2.ZERO
	return p


func _diggable_near(p: Node2D) -> DiggableSpot:
	var s: DiggableSpot = DiggableScene.instantiate()
	add_child_autofree(s)
	s.global_position = p.global_position + Vector2(30, 0)  # within ASSIST_RANGE (48)
	return s


func test_terrified_briar_still_lets_rowan_dig_by_hand() -> void:
	var p := _player()
	var spot := _diggable_near(p)
	var briar: CompanionBase = load("res://scenes/companions/briar.tscn").instantiate()
	add_child_autofree(briar)
	briar.global_position = p.global_position
	await wait_physics_frames(1)
	DreadManager.add_dread(100.0)  # terrify Briar -> command_dig refuses
	assert_true(briar.is_afraid(), "Briar is too afraid to dig")
	assert_false(spot.revealed, "not dug yet")
	p._try_companion_assist()
	assert_true(spot.revealed, "Briar refused -> Rowan uncovers it by hand (no-missable)")


func test_no_companion_hand_dig_still_works() -> void:  # regression
	var p := _player()
	var spot := _diggable_near(p)
	await wait_physics_frames(1)
	assert_false(spot.revealed)
	p._try_companion_assist()
	assert_true(spot.revealed, "no dog present -> hand dig (unchanged)")
