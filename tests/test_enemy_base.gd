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
