extends GutTest
## Village green solids (Bite C2): building footprints + prop solids leave
## door approaches open; eavesdrop zones stay Area2D (walkable).

func test_village_borders_and_world_solids() -> void:
	var zone: Node2D = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var borders := zone.get_node("Borders") as StaticBody2D
	assert_eq(borders.collision_layer, 1, "village borders on world layer")
	var solids := zone.get_node_or_null("WorldSolids") as StaticBody2D
	assert_not_null(solids, "WorldSolids for well/bench/trees")
	assert_eq(solids.collision_layer, 1)
	var prop_shapes := 0
	for c in solids.get_children():
		if c is CollisionShape2D and (c as CollisionShape2D).shape != null:
			prop_shapes += 1
	assert_gt(prop_shapes, 3, "well, bench, market, trees…")


func test_village_has_named_building_footprints() -> void:
	var zone: Node2D = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	for name in ["BldMarta", "BldChurch", "BldSmith", "BldCotL", "BldCotR"]:
		var sh := zone.get_node_or_null("Borders/" + name) as CollisionShape2D
		assert_not_null(sh, "%s footprint exists" % name)
		assert_not_null(sh.shape, "%s has a shape" % name)


func test_doors_sit_outside_building_footprints() -> void:
	## Door centers must not lie inside their building rect (soft-lock risk).
	var zone: Node2D = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var pairs := [
		["MartaHouseDoor", "Borders/BldMarta"],
		["ChapelDoor", "Borders/BldChurch"],
		["HollowHouseDoor", "Borders/BldCotR"],
	]
	for pair: Array in pairs:
		var door: Node2D = zone.get_node(pair[0])
		var bld := zone.get_node(pair[1]) as CollisionShape2D
		var rect := bld.shape as RectangleShape2D
		assert_not_null(rect, "%s is a rectangle footprint" % pair[1])
		var half := rect.size * 0.5
		var local := door.global_position - bld.global_position
		var inside := absf(local.x) <= half.x and absf(local.y) <= half.y
		assert_false(inside, "%s must stay outside %s for approach" % [pair[0], pair[1]])


func test_eavesdrop_zones_remain_walkable_areas() -> void:
	var zone: Node2D = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	assert_true(zone.get_node("EavesdropWell") is Area2D)
	assert_true(zone.get_node("EavesdropBench") is Area2D)
	assert_true(zone.get_node("EavesdropMarket") is Area2D)
