extends GutTest
## Health component contract.

var health: Health


func before_each() -> void:
	health = Health.new()
	health.max_hp = 5
	health.invuln_seconds = 0.0
	add_child_autofree(health)


func test_starts_at_max() -> void:
	assert_eq(health.hp, 5)
	assert_false(health.is_dead())


func test_damage_reduces_and_signals() -> void:
	watch_signals(health)
	assert_true(health.take_damage(2))
	assert_eq(health.hp, 3)
	assert_signal_emitted(health, "damaged")
	assert_signal_emitted_with_parameters(health, "hp_changed", [3, 5])


func test_lethal_damage_clamps_and_dies_once() -> void:
	watch_signals(health)
	health.take_damage(99)
	assert_eq(health.hp, 0)
	assert_true(health.is_dead())
	assert_signal_emit_count(health, "died", 1)
	assert_false(health.take_damage(1), "dead targets take no damage")


func test_invuln_window_blocks_repeat_hits() -> void:
	health.invuln_seconds = 10.0
	assert_true(health.take_damage(1))
	assert_false(health.take_damage(1), "second hit inside invuln window ignored")
	assert_eq(health.hp, 4)


func test_zero_or_negative_damage_ignored() -> void:
	assert_false(health.take_damage(0))
	assert_false(health.take_damage(-3))
	assert_eq(health.hp, 5)


func test_heal_clamps_to_max_and_not_dead() -> void:
	health.take_damage(3)
	health.heal(99)
	assert_eq(health.hp, 5)
	health.take_damage(99)
	health.heal(1)
	assert_eq(health.hp, 0, "no healing the dead")
	health.restore_full()
	assert_eq(health.hp, 5)
