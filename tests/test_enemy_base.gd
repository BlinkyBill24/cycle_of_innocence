extends GutTest
## Twisted Child / EnemyBase: scene integrity, HSM wiring, perception, mercy stubs.

var enemy: EnemyBase


func before_each() -> void:
	enemy = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)


func test_scene_wires_components() -> void:
	assert_not_null(enemy.health)
	assert_not_null(enemy.hurtbox)
	assert_not_null(enemy.lunge_hitbox)
	assert_eq(enemy.hurtbox.faction, &"enemy")
	assert_eq(enemy.lunge_hitbox.faction, &"enemy")
	assert_eq(enemy.enemy_kind, &"twisted_child")


func test_hsm_starts_in_patrol() -> void:
	assert_not_null(enemy.hsm)
	assert_true(enemy.hsm.is_active())
	assert_eq(enemy.hsm.get_active_state(), enemy._state_patrol)


func test_mercy_stubs_present() -> void:
	assert_true(enemy.spareable)
	assert_eq(enemy.recognition, 0.0)
	assert_false(enemy.stilled)


func test_no_player_means_no_detection() -> void:
	assert_eq(enemy.distance_to_player(), INF)
	assert_false(enemy.can_see_player())


func test_detects_player_in_range_and_chases() -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(50, 0)
	await wait_physics_frames(3)
	assert_true(enemy.can_see_player())
	assert_eq(enemy.hsm.get_active_state(), enemy._state_chase)


func test_stilled_disables_detection() -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(50, 0)
	enemy.stilled = true
	assert_false(enemy.can_see_player())


func test_player_out_of_radius_not_seen() -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(500, 0)
	assert_false(enemy.can_see_player())


func test_death_emits_enemy_died() -> void:
	watch_signals(GameEvents)
	enemy.health.take_damage(99)
	assert_signal_emitted_with_parameters(GameEvents, "enemy_died", [&"twisted_child"])


func _spawn_player_at(offset: Vector2) -> CharacterBody2D:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + offset
	return player


func test_point_blank_contact_backs_out_instead_of_gluing() -> void:
	# regression (playtest 2026-06-11): a lunge ends at body contact (~18px);
	# the old standoff froze there and re-lunged point-blank forever
	_spawn_player_at(Vector2(12, 0))
	enemy._cooldown = 999.0  # isolate the retreat: no bite this test
	enemy.hsm.dispatch(&"spotted")
	var start := enemy.distance_to_player()
	await wait_physics_frames(30)
	assert_eq(enemy.hsm.get_active_state(), enemy._state_chase, "no point-blank lunge")
	assert_gt(enemy.distance_to_player(), start + 4.0, "backs out toward the hover ring")


func test_still_attacks_from_the_hover_ring() -> void:
	_spawn_player_at(Vector2(24, 0))
	enemy.hsm.dispatch(&"spotted")
	await wait_physics_frames(2)
	assert_eq(enemy.hsm.get_active_state(), enemy._state_attack, "ring distance still bites")


func test_domination_retags_the_lunge_as_an_ally_attack() -> void:
	# Dispatch the state directly (skips add_domination's PlayerData side effects).
	assert_eq(enemy.lunge_hitbox.faction, &"enemy", "a free monster's lunge hurts Rowan")
	enemy.hsm.dispatch(&"dominated")
	await wait_physics_frames(1)
	assert_eq(enemy.lunge_hitbox.faction, Faction.ALLY,
		"a Dominated thrall's lunge fights FOR Rowan (ally), so it wounds enemies, not him")


func test_monster_freezes_while_a_modal_is_open() -> void:
	# satchel/journal/dialogue emit exploration_paused — the monster must hold still
	# (playtest: monsters kept moving under the open inventory).
	assert_true(enemy.hsm.is_active(), "live by default")
	GameEvents.exploration_paused.emit()
	enemy.global_position = Vector2.ZERO
	enemy.velocity = Vector2(140, 0)  # pretend it was mid-lunge
	await wait_physics_frames(2)
	assert_eq(enemy.velocity, Vector2.ZERO, "paused monster is forced to a stop")
	assert_almost_eq(enemy.global_position.x, 0.0, 0.5, "and does not drift under the menu")
	assert_false(enemy.hsm.is_active(), "its brain is paused too — no chasing or lunging")
	GameEvents.exploration_resumed.emit()
	assert_true(enemy.hsm.is_active(), "and it wakes when the world resumes")


func test_fringes_zone_has_two_distinct_monsters_to_verify_factions() -> void:
	# A second monster gives a Dominated thrall something to fight (faction demo).
	var zone: Node2D = load("res://scenes/zones/fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var ids := {}
	for node in zone.find_children("*", "EnemyBase", true, false):
		var e := node as EnemyBase
		if e:
			ids[e.stable_id] = true
	assert_eq(ids.size(), 2, "fringes authors two monsters")
	assert_true(ids.has(&"twisted_child_01"), "the original monster")
	assert_true(ids.has(&"twisted_child_02"), "a second, with a UNIQUE stable_id (flag bookkeeping)")


func test_fringes_monsters_spawn_far_enough_to_engage_one_at_a_time() -> void:
	# playtest: clustered spawns mobbed the player, making a defenseless soothe (and the
	# dig before it) impossible. They must start > 2x detection_radius (110) apart so
	# approaching one keeps the player outside the other's notice.
	var state: SceneState = (load("res://scenes/zones/fringes.tscn") as PackedScene).get_state()
	var positions: Array[Vector2] = []
	for i in state.get_node_count():
		var inst: PackedScene = state.get_node_instance(i)
		if inst != null and inst.resource_path == "res://scenes/enemies/twisted_child.tscn":
			for p in state.get_node_property_count(i):
				if String(state.get_node_property_name(i, p)) == "position":
					positions.append(state.get_node_property_value(i, p))
	assert_eq(positions.size(), 2, "two monsters placed in the fringes")
	assert_gt(positions[0].distance_to(positions[1]), 220.0,
		"monsters spawn far enough apart to face one at a time (not mobbed)")


func test_fringes_monster_soothe_key_is_diggable_in_the_same_zone() -> void:
	# playtest: the key pointed at the playground rabbit while the monsters live in the
	# fringes -> impossible to satisfy in-zone, so the soothe always plateaued. Each
	# monster's key must correspond to a dig present in THIS scene.
	var state: SceneState = (load("res://scenes/zones/fringes.tscn") as PackedScene).get_state()
	var monster_keys: Array[StringName] = []
	var diggable_flags := {}  # "dug_<spot_id>" for every diggable in the scene
	for i in state.get_node_count():
		var inst: PackedScene = state.get_node_instance(i)
		if inst == null:
			continue
		if inst.resource_path == "res://scenes/enemies/twisted_child.tscn":
			var key: StringName = &"dug_playground_buried_toy"  # script default
			for p in state.get_node_property_count(i):
				if String(state.get_node_property_name(i, p)) == "soothe_key_flag":
					key = state.get_node_property_value(i, p)
			monster_keys.append(key)
		elif inst.resource_path == "res://scenes/world/diggable_spot.tscn":
			var spot_id: StringName = &"playground_buried_toy"  # script default
			for p in state.get_node_property_count(i):
				if String(state.get_node_property_name(i, p)) == "spot_id":
					spot_id = state.get_node_property_value(i, p)
			diggable_flags[StringName("dug_" + String(spot_id))] = true
	assert_eq(monster_keys.size(), 2, "two monsters")
	for key: StringName in monster_keys:
		assert_true(diggable_flags.has(key),
			"the monster's soothe key (%s) is diggable in the fringes, not another zone" % key)
