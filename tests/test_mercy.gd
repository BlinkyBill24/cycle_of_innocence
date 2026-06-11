extends GutTest
## Full mercy (encounters-mercy.md): generic plateau vs the specific key,
## Briar's calm aura, Stilled persistence + leading, betrayal, Domination.

var enemy: EnemyBase


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	enemy = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func test_generic_soothe_plateaus_without_the_key() -> void:
	assert_false(enemy.add_recognition(50.0), "halfway is not stilled yet")
	assert_false(enemy.add_recognition(50.0), "the generic lullaby is not enough")
	assert_eq(enemy.recognition, 60.0, "plateaus at GENERIC_PLATEAU")
	assert_false(enemy.stilled)


func test_specific_key_unlocks_full_stilling() -> void:
	watch_signals(GameEvents)
	assert_false(enemy.add_recognition(50.0, true), "halfway is not stilled yet")
	assert_true(enemy.add_recognition(50.0, true), "threshold reached with the key")
	assert_true(enemy.stilled)
	assert_eq(enemy.hsm.get_active_state(), enemy._state_stilled)
	assert_signal_emitted_with_parameters(GameEvents, "monster_stilled", [&"twisted_child_01"])
	assert_true(PlayerData.has_story_flag(&"stilled_twisted_child_01"))
	assert_true(PlayerData.has_story_flag(&"spared_twisted_child_01"), "choice-matrix history")
	assert_eq(PlayerData.spared_count, 1)
	assert_eq(PlayerData.morality, -5.0, "sparing pulls toward Empath")


func test_digging_up_the_toy_is_the_key() -> void:
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.reveal()
	assert_true(PlayerData.has_story_flag(enemy.soothe_key_flag),
			"the buried toy IS the TwistedChild's soothe key")


func test_soothe_rate_rule() -> void:
	assert_eq(PlayerController.soothe_rate(30.0, 0.0, false, false), 30.0)
	assert_eq(PlayerController.soothe_rate(30.0, 0.0, true, false), 48.0, "key x1.6")
	assert_eq(PlayerController.soothe_rate(30.0, 0.0, false, true), 45.0, "Briar calm x1.5")
	assert_eq(PlayerController.soothe_rate(30.0, 0.0, true, true), 72.0, "they stack")
	assert_eq(PlayerController.soothe_rate(30.0, 81.0, true, true), 36.0,
			"dread > 80 halves everything — mercy is hardest when terrified")


func test_stilled_enemy_ignores_player_and_recognition() -> void:
	enemy.add_recognition(100.0, true)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(40, 0)
	assert_false(enemy.can_see_player(), "stilled monsters do not hunt")
	assert_false(enemy.add_recognition(10.0, true), "no further recognition once stilled")


func test_striking_a_stilled_monster_is_the_betrayal() -> void:
	enemy.add_recognition(100.0, true)
	var morality_after_spare := PlayerData.morality
	watch_signals(GameEvents)
	enemy.hurtbox.hit_received.emit(Hitbox.new())  # first blow against the calmed child
	assert_signal_emitted_with_parameters(GameEvents, "stilled_monster_killed", [&"twisted_child_01"])
	assert_eq(PlayerData.morality, morality_after_spare + 20.0, "heavy Vessel push on the first blow")
	assert_eq(PlayerData.get_companion(&"briar").corruption, 10.0, "Briar learns from you")
	assert_false(enemy.stilled, "it wakes and defends itself")
	assert_false(PlayerData.has_story_flag(&"stilled_twisted_child_01"), "stilled flag cleared")
	assert_eq(enemy.recognition, 50.0, "trust broken, not erased")


func test_stilled_monster_does_not_get_dragged_by_player_overlap() -> void:
	enemy.add_recognition(100.0, true)
	await wait_physics_frames(1)
	assert_eq(enemy.collision_mask, 1, "stilled: collides with world only")
	var pos := enemy.global_position
	enemy._physics_process(0.016)
	assert_eq(enemy.global_position, pos, "stilled monsters skip physics movement")


func test_stilled_state_persists_via_flag() -> void:
	PlayerData.set_story_flag(&"stilled_twisted_child_01")
	var second: EnemyBase = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(second)
	await wait_physics_frames(1)
	assert_true(second.stilled, "respawned enemy remembers being Stilled")
	assert_eq(second.hsm.get_active_state(), second._state_stilled)


func test_stilled_child_leads_to_its_secret() -> void:
	var spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(spot)
	spot.global_position = enemy.global_position + Vector2(40, 0)
	enemy.secret_spot_path = enemy.get_path_to(spot)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(30, 0)
	enemy.add_recognition(100.0, true)
	watch_signals(GameEvents)
	await wait_physics_frames(80)  # walks ~20px at 0.7x move_speed
	assert_true(PlayerData.has_story_flag(&"led_twisted_child_01"), "led once, remembered")
	assert_false(spot.revealed, "showing the way is not digging — that is Briar's moment")
	assert_signal_emitted_with_parameters(GameEvents, "stilled_led_to_secret",
			[&"twisted_child_01", &"playground_buried_toy"])
	assert_lte(enemy.global_position.distance_to(spot.global_position),
			enemy.LEAD_ARRIVE_DISTANCE + 2.0, "waits beside the spot")
	assert_gte(enemy.global_position.distance_to(spot.global_position), 10.0,
			"does not park on the marker")


func test_vessel_tier_dominates_instead() -> void:
	PlayerData.change_morality(90.0)  # Vessel tier (> 80)
	assert_eq(PlayerData.get_morality_tier(), PlayerData.MoralityTier.VESSEL)
	watch_signals(GameEvents)
	assert_true(enemy.add_domination(100.0))
	assert_true(enemy.dominated)
	assert_false(enemy.stilled, "obedience is not peace")
	assert_eq(enemy.hsm.get_active_state(), enemy._state_dominated)
	assert_signal_emitted_with_parameters(GameEvents, "monster_dominated", [&"twisted_child_01"])
	assert_true(PlayerData.has_story_flag(&"dominated_twisted_child_01"))
	assert_eq(PlayerData.dominated_count, 1)
	assert_eq(PlayerData.morality, 98.0, "domination feeds the Vessel")
	assert_eq(PlayerData.get_companion(&"briar").corruption, 5.0, "Briar watches you rule by fear")


func test_dominated_thrall_heels_beside_the_player() -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(120, 0)
	enemy.add_domination(100.0)
	enemy._dominated_update(0.016)
	assert_gt(enemy.velocity.x, 0.0, "no target to fight: follows the one it fears")
	assert_false(enemy.add_recognition(50.0, true), "a thrall cannot be soothed back")


func test_dominated_thrall_crumbles_when_its_time_runs_out() -> void:
	enemy.add_domination(100.0)
	enemy._dominated_life = 0.0
	enemy._dominated_update(0.016)
	assert_true(enemy._crumbling, "fights for you once, then dies")


func test_dominated_monster_never_respawns() -> void:
	PlayerData.set_story_flag(&"dominated_twisted_child_01")
	var second: EnemyBase = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(second)
	assert_true(second.is_queued_for_deletion(), "it stays dead across reloads")


func test_mercy_counters_survive_save_roundtrip() -> void:
	PlayerData.record_spared(&"a")
	PlayerData.record_dominated(&"b")
	var data: Dictionary = PlayerData.get_save_data()
	PlayerData.reset_to_defaults()
	PlayerData.apply_save_data(data)
	assert_eq(PlayerData.spared_count, 1)
	assert_eq(PlayerData.dominated_count, 1)
