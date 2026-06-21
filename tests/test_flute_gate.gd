extends GutTest
## The flute gates ALL soothing (decision 2026-06-21): no soothe before Rowan finds it;
## acquiring it (persisted) unlocks the EXISTING soothe entry point; playing it makes a
## diegetic sound. This goal does NOT build soothe resolution — only the gate + wiring.

func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	HollowingClock.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	HollowingClock.reset()


func _player() -> PlayerController:
	var p: PlayerController = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(p)
	p.global_position = Vector2.ZERO
	return p


func _spareable_monster_near(p: Node2D) -> EnemyBase:
	var m: EnemyBase = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(m)
	m.global_position = p.global_position + Vector2(40, 0)  # within SOOTHE_RANGE (80)
	return m


# --- acquisition unlocks, and it persists -----------------------------------

func test_acquiring_the_flute_unlocks_and_persists() -> void:
	assert_false(PlayerData.has_story_flag(&"flute_found"), "soothe locked at start")
	assert_true(Inventory.add(&"flute"), "flute acquired")
	assert_true(PlayerData.has_story_flag(&"flute_found"), "acquiring the flute unlocks soothing")
	assert_true(SaveManager.save_game(94), "save")
	PlayerData.reset_to_defaults()
	assert_false(PlayerData.has_story_flag(&"flute_found"), "scrambled")
	assert_true(SaveManager.load_game(94, false), "load")
	assert_true(PlayerData.has_story_flag(&"flute_found"), "the unlock survives save/load")
	SaveManager.delete_save(94)


func test_a_save_made_before_pickup_stays_locked() -> void:
	assert_true(SaveManager.save_game(93), "save BEFORE the flute")
	Inventory.add(&"flute")
	assert_true(PlayerData.has_story_flag(&"flute_found"))
	assert_true(SaveManager.load_game(93, false), "reload the pre-flute save")
	assert_false(PlayerData.has_story_flag(&"flute_found"),
		"the pre-flute save is still locked")
	SaveManager.delete_save(93)


# --- the gate: no soothe before the flute, soothe after ---------------------

func test_no_soothe_fires_before_the_flute() -> void:
	var p := _player()
	_spareable_monster_near(p)
	await wait_physics_frames(1)
	assert_false(p._soothe_unlocked(), "locked by default")
	p._on_interact_pressed()  # the soothe input, standing right next to a monster
	assert_false(p._soothing, "no soothe entry point fires — only fleeing remains")


func test_the_flute_invokes_the_existing_soothe() -> void:
	var p := _player()
	var m := _spareable_monster_near(p)
	await wait_physics_frames(1)
	Inventory.add(&"flute")  # unlock
	assert_true(p._soothe_unlocked())
	p._on_interact_pressed()
	assert_true(p._soothing, "with the flute, the existing soothe fires")
	assert_eq(p._soothe_target, m, "and it targets the nearby monster")


func test_playing_the_flute_makes_a_flute_sound() -> void:
	var p := _player()
	_spareable_monster_near(p)
	await wait_physics_frames(1)
	Inventory.add(&"flute")
	watch_signals(Sfx)
	p._on_interact_pressed()  # -> _start_soothe -> Sfx.play("flute")
	assert_signal_emitted_with_parameters(Sfx, "played", [&"flute"])
