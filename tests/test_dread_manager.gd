extends GutTest
## Tests for the DreadManager autoload script (fresh instance per test;
## processing disabled so decay only happens via explicit _process calls).

var dm: Node


func before_each() -> void:
	dm = load("res://scripts/autoload/dread_manager.gd").new()
	add_child_autofree(dm)
	dm.set_process(false)


func test_add_dread_clamps_and_signals() -> void:
	watch_signals(dm)
	dm.add_dread(150.0)
	assert_eq(dm.dread, dm.DREAD_MAX)
	assert_signal_emitted(dm, "dread_changed")


func test_reduce_dread_floors_at_zero() -> void:
	dm.add_dread(10.0)
	dm.reduce_dread(50.0)
	assert_eq(dm.dread, 0.0)


func test_tier_boundaries() -> void:
	var cases := [
		[0.0, dm.DreadTier.CALM],
		[25.0, dm.DreadTier.CALM],
		[25.1, dm.DreadTier.UNEASY],
		[60.0, dm.DreadTier.UNEASY],
		[60.1, dm.DreadTier.FEARFUL],
		[85.0, dm.DreadTier.FEARFUL],
		[85.1, dm.DreadTier.TERROR],
		[100.0, dm.DreadTier.TERROR],
	]
	for case: Array in cases:
		dm.dread = case[0]
		assert_eq(dm.get_tier(), case[1], "dread %s should be tier %s" % [case[0], case[1]])


func test_tier_changed_signal_on_crossing() -> void:
	watch_signals(dm)
	dm.add_dread(30.0)
	assert_signal_emitted_with_parameters(dm, "dread_tier_changed", [dm.DreadTier.UNEASY])


func test_decays_toward_zero_baseline() -> void:
	dm.add_dread(50.0)
	dm._process(1.0)
	assert_eq(dm.dread, 50.0 - dm.DECAY_PER_SECOND)
	# never undershoots the baseline
	dm._process(1000.0)
	assert_eq(dm.dread, 0.0)


func test_rises_toward_active_zone_baseline() -> void:
	GameEvents.dread_zone_entered.emit(&"test_zone")
	assert_eq(dm.get_zone_baseline(), dm.DEFAULT_ZONE_BASELINE)
	dm._process(1.0)
	assert_eq(dm.dread, dm.RISE_PER_SECOND)
	dm._process(1000.0)
	assert_eq(dm.dread, dm.DEFAULT_ZONE_BASELINE)
	GameEvents.dread_zone_exited.emit(&"test_zone")
	assert_eq(dm.get_zone_baseline(), 0.0)


func test_registered_zone_level_and_max_of_overlapping_zones() -> void:
	dm.register_zone_level(&"ritual_site", 80.0)
	GameEvents.dread_zone_entered.emit(&"ritual_site")
	GameEvents.dread_zone_entered.emit(&"unregistered")
	assert_eq(dm.get_zone_baseline(), 80.0)
	GameEvents.dread_zone_exited.emit(&"ritual_site")
	assert_eq(dm.get_zone_baseline(), dm.DEFAULT_ZONE_BASELINE)
	GameEvents.dread_zone_exited.emit(&"unregistered")


func test_revelation_event_raises_dread() -> void:
	GameEvents.revelation_unlocked.emit(&"monsters_are_children")
	assert_eq(dm.dread, dm.REVELATION_DREAD)


func test_heavy_companion_corruption_raises_dread() -> void:
	GameEvents.companion_corrupted.emit(&"briar", 50.0)
	assert_eq(dm.dread, 0.0, "below threshold should not raise dread")
	GameEvents.companion_corrupted.emit(&"briar", 75.0)
	assert_eq(dm.dread, dm.COMPANION_CORRUPTION_DREAD)


func test_stamina_multiplier_endpoints() -> void:
	assert_eq(dm.get_stamina_regen_multiplier(), 1.0)
	dm.add_dread(100.0)
	assert_eq(dm.get_stamina_regen_multiplier(), 0.5)


func test_horror_intensity_scales_presentation_only() -> void:
	dm.add_dread(100.0)
	dm.set_horror_intensity(0.0)
	assert_eq(dm.get_presentation_strength(), 0.0, "presentation muted at intensity 0")
	assert_eq(dm.get_stamina_regen_multiplier(), 0.5, "mechanics unaffected by intensity")
	assert_eq(dm.get_companion_reliability(), 0.6, "mechanics unaffected by intensity")


func test_reset_clears_dread_and_zones() -> void:
	GameEvents.dread_zone_entered.emit(&"test_zone")
	dm.add_dread(60.0)
	dm.reset()
	assert_eq(dm.dread, 0.0)
	assert_eq(dm.get_zone_baseline(), 0.0)
	assert_eq(dm.get_tier(), dm.DreadTier.CALM)
