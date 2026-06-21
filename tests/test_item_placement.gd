extends GutTest
## Item world-placement (Wiring & Audibility pass, item 4): berries + weapons are
## now findable via ForageSpot pickups in playground/fringes (dig-up items were
## already placed). A placed item picks up into the satchel.


func test_forage_grant_adds_a_placed_item_to_inventory() -> void:
	PlayerData.reset_to_defaults()
	var spot := ForageSpot.new()
	spot.item_id = &"forest_berries"
	spot.quantity = 2
	add_child_autofree(spot)
	assert_false(Inventory.has(&"forest_berries"), "not held before pickup")
	assert_true(spot.grant(), "walking over a forage spot grants it")
	assert_true(Inventory.has(&"forest_berries"), "the placed item lands in the satchel")
	assert_eq(Inventory.quantity_of(&"forest_berries"), 2, "granted quantity is correct")
	assert_false(spot.grant(), "one-shot — a second grant is a no-op")


# --- persistence: a foraged spot must NOT reappear on revisit / reload -------
# (playtest 2026-06-21: re-entering re-foraged the slingshot/stones into duplicate slots)

func test_foraging_persists_a_one_shot_flag() -> void:
	PlayerData.reset_to_defaults()
	var spot := ForageSpot.new()
	spot.name = "StonesForage"
	spot.item_id = &"sling_stones"
	add_child_autofree(spot)
	await wait_physics_frames(1)
	assert_false(PlayerData.has_story_flag(&"foraged_StonesForage"), "not foraged yet")
	spot.grant()
	assert_true(PlayerData.has_story_flag(&"foraged_StonesForage"),
		"foraging persists a one-shot flag (survives save/load + re-entry)")


func test_already_foraged_spot_is_inert_on_revisit() -> void:
	PlayerData.reset_to_defaults()
	PlayerData.set_story_flag(&"foraged_SlingshotForage")  # foraged on a prior visit/save
	var spot := ForageSpot.new()
	spot.name = "SlingshotForage"
	spot.item_id = &"slingshot"
	add_child_autofree(spot)
	await wait_physics_frames(1)
	assert_false(spot.monitoring, "an already-foraged spot is inert on revisit")
	assert_false(spot.grant(), "and won't re-grant -> no duplicate slingshot")


func test_playground_places_berries_and_weapons() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var placed := {}
	for node in get_tree().get_nodes_in_group("forage_spot"):
		var spot := node as ForageSpot
		if spot:
			placed[spot.item_id] = true
	for expected: StringName in [&"forest_berries", &"sturdy_stick", &"slingshot", &"sling_stones"]:
		assert_true(placed.has(expected), "%s is placed in the world to be found" % expected)
