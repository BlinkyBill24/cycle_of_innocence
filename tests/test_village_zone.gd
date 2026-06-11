extends GutTest
## Village zone painter + real zone transitions (the second zone).

const Zone := preload("res://scripts/world/village_green.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	ZoneManager.current_zone_id = &""
	ZoneManager.arriving_from = &""


func test_no_cell_mixes_cobble_and_yard() -> void:
	# only GREEN<->COBBLE and GREEN<->YARD tilesets exist
	var bad := 0
	for y in range(-Zone.HEIGHT / 2, Zone.HEIGHT / 2):
		for x in range(-Zone.WIDTH / 2, Zone.WIDTH / 2):
			var kinds := {}
			for c in [Zone.vertex_terrain(x, y), Zone.vertex_terrain(x + 1, y),
					Zone.vertex_terrain(x, y + 1), Zone.vertex_terrain(x + 1, y + 1)]:
				kinds[c] = true
			if kinds.has(Zone.Terrain.COBBLE) and kinds.has(Zone.Terrain.YARD):
				bad += 1
			elif kinds.size() > 2:
				bad += 1
	assert_eq(bad, 0, "no cell pairs terrains without a transition tileset")


func test_wang_bitmask_and_pure_tiles() -> void:
	assert_eq(Zone.wang_tile(Zone.Terrain.GREEN, Zone.Terrain.GREEN,
			Zone.Terrain.GREEN, Zone.Terrain.GREEN), [Zone.SRC_GREEN_COBBLE, Vector2i(0, 0)])
	assert_eq(Zone.wang_tile(Zone.Terrain.YARD, Zone.Terrain.YARD,
			Zone.Terrain.YARD, Zone.Terrain.YARD), [Zone.SRC_GREEN_YARD, Vector2i(3, 3)])
	assert_eq(Zone.wang_tile(Zone.Terrain.GREEN, Zone.Terrain.COBBLE,
			Zone.Terrain.GREEN, Zone.Terrain.GREEN), [Zone.SRC_GREEN_COBBLE, Vector2i(0, 1)])


func test_transition_registry_covers_both_zones() -> void:
	for zone_id in [&"playground_fringes", &"village_edge"]:
		var path: String = ZoneManager.ZONE_SCENES[zone_id]
		assert_true(ResourceLoader.exists(path), "%s scene exists" % zone_id)


func test_entry_placement_uses_matching_marker() -> void:
	ZoneManager.current_zone_id = &"playground_fringes"
	ZoneManager.enter_zone(&"village_edge")
	assert_eq(ZoneManager.arriving_from, &"playground_fringes")
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	var entry := Node2D.new()
	entry.add_to_group("entry_from_playground_fringes")
	add_child_autofree(entry)
	entry.global_position = Vector2(620, 0)
	ZoneManager.place_player_at_entry(self)
	assert_eq(player.global_position, Vector2(620, 0), "spawned at the matching gate")
	assert_eq(ZoneManager.arriving_from, &"", "entry intent consumed")
