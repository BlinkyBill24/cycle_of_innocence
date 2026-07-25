extends GutTest
## Playground prop solids (Bite C1): Rowan collides with world layer 1 solids
## under equipment / totem / post / campfire — surface/forage areas stay walkable.

func test_player_collides_with_world_layer() -> void:
	var p: CharacterBody2D = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(p)
	# layer 1 (world) + layer 3 — see player.tscn collision_mask = 5
	assert_ne(p.collision_mask & 1, 0, "player must collide with world solids (layer 1)")


func test_playground_world_solids_exist() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var solids := zone.get_node_or_null("WorldSolids") as StaticBody2D
	assert_not_null(solids, "WorldSolids keeps residual footprints (lottery)")
	assert_eq(solids.collision_layer, 1, "solids live on world layer 1")
	assert_eq(solids.collision_mask, 0, "solids do not scan other layers")


func test_playground_t1_props_on_ground_plate() -> void:
	## T1 hybrid: ground-only paint + y-sorted prop StaticBody2D with sprites.
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var world := zone.get_node("World") as Node2D
	assert_true(world.y_sort_enabled, "World y-sorts props")
	for n: String in [
		"PropRoundabout", "PropSlide", "PropSwingLeft", "PropSwingSouth",
		"PropCultTotem", "PropTreeNW", "PropTreeSE", "PropToyDuck", "PropTreeNE",
	]:
		var body := world.get_node_or_null(n) as StaticBody2D
		assert_not_null(body, "%s solid prop" % n)
		assert_eq(body.collision_layer, 1)
		assert_not_null((body.get_node("Sprite2D") as Sprite2D).texture, "%s has art" % n)


func test_campfire_and_borders_are_solid() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var borders := zone.get_node("Borders") as StaticBody2D
	assert_eq(borders.collision_layer, 1, "map borders block walking")
	var fire := zone.get_node("Hideout/Campfire") as StaticBody2D
	assert_eq(fire.collision_layer, 1, "campfire blocks walking")


func test_forage_and_surface_zones_are_not_static_bodies() -> void:
	# Walkable systems stay Area2D — blocking them would soft-lock the food path.
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	assert_true(zone.get_node("BerryForage") is Area2D, "berries stay walk-over pickups")
	assert_true(zone.get_node("SandPit") is Area2D, "sand surface is not a solid wall")
	assert_true(zone.get_node("PathHub") is Area2D, "path hub is not a solid wall")
