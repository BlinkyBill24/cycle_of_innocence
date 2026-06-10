extends GutTest
## Smoke tests for PlayerData progression core (morality tiers, clamping, companions, revelations).

var pd: Node


func before_each() -> void:
	pd = load("res://scripts/autoload/player_data.gd").new()
	add_child_autofree(pd)


func test_morality_tier_boundaries() -> void:
	var cases := [
		[-100.0, pd.MoralityTier.INNOCENT_EMPATH],
		[-40.0, pd.MoralityTier.INNOCENT_EMPATH],
		[-39.9, pd.MoralityTier.WOUNDED],
		[0.0, pd.MoralityTier.WOUNDED],
		[39.0, pd.MoralityTier.WOUNDED],
		[39.1, pd.MoralityTier.HARDENED],
		[80.0, pd.MoralityTier.HARDENED],
		[80.1, pd.MoralityTier.VESSEL],
		[100.0, pd.MoralityTier.VESSEL],
	]
	for case: Array in cases:
		pd.morality = case[0]
		assert_eq(pd.get_morality_tier(), case[1], "morality %s should be tier %s" % [case[0], case[1]])


func test_change_morality_clamps_to_range() -> void:
	pd.change_morality(500.0)
	assert_eq(pd.morality, pd.MORALITY_MAX)
	pd.change_morality(-500.0)
	assert_eq(pd.morality, pd.MORALITY_MIN)


func test_vessel_tier_sets_marked_appearance_flag() -> void:
	pd.change_morality(100.0)
	assert_has(pd.appearance_flags, &"marked")


func test_companion_bond_and_corruption_clamp() -> void:
	pd.set_companion_bond(pd.BRIAR_ID, 150.0)
	assert_eq(pd.get_companion(pd.BRIAR_ID).bond, pd.BOND_MAX)
	pd.set_companion_corruption(pd.BRIAR_ID, -10.0)
	assert_eq(pd.get_companion(pd.BRIAR_ID).corruption, pd.CORRUPTION_MIN)


func test_slice_companions_initialized_with_briar_bond() -> void:
	assert_eq(pd.get_companion(pd.BRIAR_ID).bond, 25.0)
	assert_true(pd.get_companion(pd.BRIAR_ID).alive)


func test_revelations_dedupe_and_query() -> void:
	pd.unlock_revelation(&"monsters_are_children")
	pd.unlock_revelation(&"monsters_are_children")
	assert_eq(pd.known_revelations.size(), 1)
	assert_true(pd.is_revelation_known(&"monsters_are_children"))
	assert_false(pd.is_revelation_known(&"elders_are_survivors"))


func test_reset_to_defaults_restores_slice_state() -> void:
	pd.change_morality(60.0)
	pd.set_age_stage(pd.AgeStage.ADULT)
	pd.unlock_revelation(&"x")
	pd.reset_to_defaults()
	assert_eq(pd.morality, 0.0)
	assert_eq(pd.age_stage, pd.AgeStage.CHILD)
	assert_eq(pd.known_revelations.size(), 0)
	assert_eq(pd.get_companion(pd.BRIAR_ID).bond, 25.0)
