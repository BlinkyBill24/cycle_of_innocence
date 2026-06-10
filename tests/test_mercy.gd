extends GutTest
## Mercy v1: Recognition -> Stilled, persistence flag, morality economics.

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


func test_recognition_fills_to_stilled() -> void:
	watch_signals(GameEvents)
	assert_false(enemy.add_recognition(50.0), "halfway is not stilled yet")
	assert_true(enemy.add_recognition(50.0), "threshold reached")
	assert_true(enemy.stilled)
	assert_eq(enemy.hsm.get_active_state(), enemy._state_stilled)
	assert_signal_emitted_with_parameters(GameEvents, "monster_stilled", [&"twisted_child_01"])
	assert_true(PlayerData.has_story_flag(&"stilled_twisted_child_01"))
	assert_eq(PlayerData.morality, -5.0, "sparing pulls toward Empath")


func test_stilled_enemy_ignores_player_and_recognition() -> void:
	enemy.add_recognition(100.0)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = enemy.global_position + Vector2(40, 0)
	assert_false(enemy.can_see_player(), "stilled monsters do not hunt")
	assert_false(enemy.add_recognition(10.0), "no further recognition once stilled")


func test_striking_a_stilled_monster_is_the_betrayal() -> void:
	enemy.add_recognition(100.0)
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
	enemy.add_recognition(100.0)
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
