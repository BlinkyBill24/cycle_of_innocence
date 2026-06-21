extends GutTest
## Food healing (HEAL path, decision 2026-06-21): eating a food heals Rowan by its
## heal_hearts (clamped to the 10-heart / 20-HP max), consumes one, and persists. The
## eat verb is GENERIC (reads heal_hearts) so medicine reuses it. 1 heart = 2 HP.


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func _player() -> PlayerController:
	var p: PlayerController = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(p)
	return p


# --- heal by the item's value (berries 1, meat 2, treat 3, meal 4 hearts) ---

func test_eating_heals_by_the_items_value_and_consumes_one() -> void:
	var p := _player()
	await wait_physics_frames(1)
	for case: Array in [[&"forest_berries", 2], [&"dried_meat", 4], [&"honeycomb", 6], [&"hearty_meal", 8]]:
		var id: StringName = case[0]
		var hp_gain: int = case[1]  # hearts x 2
		p.health.restore_to(4)  # low enough that the heal fits without clamping
		Inventory.add(id)
		var before := PlayerData.current_hp
		assert_true(Inventory.eat(id), "%s is eaten" % id)
		assert_eq(PlayerData.current_hp, before + hp_gain, "%s heals %d HP" % [id, hp_gain])
		assert_eq(Inventory.quantity_of(id), 0, "%s consumes exactly one" % id)


func test_eating_cannot_overheal_past_the_max() -> void:
	var p := _player()
	await wait_physics_frames(1)
	p.health.restore_to(19)  # 1 HP below the 20-HP / 10-heart cap
	Inventory.add(&"hearty_meal")  # 4 hearts = 8 HP
	assert_true(Inventory.eat(&"hearty_meal"))
	assert_eq(PlayerData.current_hp, 20, "clamped at the max — never overheal")
	assert_eq(Inventory.quantity_of(&"hearty_meal"), 0, "still consumed on the clamp branch")


func test_eating_at_full_health_does_nothing_and_keeps_the_food() -> void:
	var p := _player()
	await wait_physics_frames(1)
	p.health.restore_to(20)  # full
	Inventory.add(&"forest_berries")
	assert_false(Inventory.eat(&"forest_berries"), "full -> not eaten")
	assert_eq(Inventory.quantity_of(&"forest_berries"), 1, "no waste — the food is kept")
	assert_eq(PlayerData.current_hp, 20)


func test_cannot_eat_food_you_do_not_have() -> void:
	assert_false(Inventory.eat(&"honeycomb"), "can't eat what you don't hold")


func test_eating_emits_the_heal_request_with_the_right_hp() -> void:
	# the load-bearing contract: eat -> player_heal_requested(hp) -> Health.heal -> HUD repaint
	var p := _player()
	await wait_physics_frames(1)
	p.health.restore_to(6)
	Inventory.add(&"dried_meat")  # 2 hearts
	watch_signals(GameEvents)
	assert_true(Inventory.eat(&"dried_meat"))
	assert_signal_emitted_with_parameters(GameEvents, "player_heal_requested", [4])  # 2 hearts x 2


func test_eating_plays_a_diegetic_eat_sound() -> void:
	var p := _player()
	await wait_physics_frames(1)
	p.health.restore_to(10)
	Inventory.add(&"forest_berries")
	watch_signals(Sfx)
	Inventory.eat(&"forest_berries")
	assert_signal_emitted_with_parameters(Sfx, "played", [&"eat"])


# --- persistence ------------------------------------------------------------

func test_health_and_food_survive_save_load() -> void:
	var p := _player()
	await wait_physics_frames(1)
	p.health.restore_to(10)  # mid-game health
	Inventory.add(&"forest_berries", 3)
	assert_true(SaveManager.save_game(92), "save")
	p.health.restore_to(20)            # scramble live state
	PlayerData.reset_to_defaults()     # scramble persisted state
	assert_true(SaveManager.load_game(92, false), "load")
	assert_eq(PlayerData.current_hp, 10, "current health is preserved")
	assert_eq(Inventory.quantity_of(&"forest_berries"), 3, "food counts are preserved")
	SaveManager.delete_save(92)


func test_a_loaded_player_restores_saved_health_not_full() -> void:
	# the persistence fix: _ready restores PlayerData.current_hp, not full
	PlayerData.current_hp = 12  # as if a save with 12/20 was loaded
	var p := _player()
	await wait_physics_frames(1)
	assert_eq(p.health.hp, 12, "a loaded player restores SAVED health, not full")
	assert_eq(PlayerData.current_hp, 12)
