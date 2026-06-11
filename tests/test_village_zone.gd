extends GutTest
## Village zone painter + real zone transitions (the second zone).

const Zone := preload("res://scripts/world/village_green.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	ZoneManager.current_zone_id = &""
	ZoneManager.arriving_from = &""


func test_wang_bitmask_and_pure_tiles() -> void:
	assert_eq(Zone.wang_tile(Zone.Terrain.GREEN, Zone.Terrain.GREEN,
			Zone.Terrain.GREEN, Zone.Terrain.GREEN), [Zone.SRC_GREEN_YARD, Vector2i(0, 0)])
	assert_eq(Zone.wang_tile(Zone.Terrain.DIRT, Zone.Terrain.DIRT,
			Zone.Terrain.DIRT, Zone.Terrain.DIRT), [Zone.SRC_GREEN_YARD, Vector2i(3, 3)])
	assert_eq(Zone.wang_tile(Zone.Terrain.GREEN, Zone.Terrain.DIRT,
			Zone.Terrain.GREEN, Zone.Terrain.GREEN), [Zone.SRC_GREEN_YARD, Vector2i(0, 1)])


func test_paths_yards_and_forecourt_are_dirt() -> void:
	# the ring (vertex ~(7.5, 0)), the west-east lane, a yard, the forecourt
	assert_eq(Zone.vertex_terrain(7, 0), Zone.Terrain.DIRT, "ring")
	assert_eq(Zone.vertex_terrain(-20, 0), Zone.Terrain.DIRT, "west lane")
	assert_eq(Zone.vertex_terrain(-14, -9), Zone.Terrain.DIRT, "NW yard")
	assert_eq(Zone.vertex_terrain(0, -12), Zone.Terrain.DIRT, "chapel forecourt")
	assert_eq(Zone.vertex_terrain(-3, 3), Zone.Terrain.GREEN, "the green inside the ring")


func test_transition_registry_covers_both_zones() -> void:
	for zone_id in [&"playground_fringes", &"village_edge"]:
		var path: String = ZoneManager.ZONE_SCENES[zone_id]
		assert_true(ResourceLoader.exists(path), "%s scene exists" % zone_id)


func test_both_zones_have_return_entries() -> void:
	# regression (playtest 2026-06-11): returning to the playground dropped
	# Rowan at the scene-default plaza spawn instead of the west gate
	var expectations := {
		"res://scenes/zones/playground_fringes.tscn": "entry_from_village_edge",
		"res://scenes/zones/village_green.tscn": "entry_from_playground_fringes",
	}
	for path: String in expectations:
		var state: SceneState = (load(path) as PackedScene).get_state()
		var found := false
		for i in state.get_node_count():
			for group in state.get_node_groups(i):
				if group == expectations[path]:
					found = true
		assert_true(found, "%s has %s" % [path.get_file(), expectations[path]])


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
	var companion := CharacterBody2D.new()
	companion.add_to_group("companion")
	add_child_autofree(companion)
	companion.global_position = Vector2(-300, -180)  # scene-default, far away
	ZoneManager.place_player_at_entry(self)
	assert_eq(player.global_position, Vector2(620, 0), "spawned at the matching gate")
	assert_lt(companion.global_position.distance_to(player.global_position), 40.0,
			"the family crosses together")
	assert_eq(ZoneManager.arriving_from, &"", "entry intent consumed")


func test_world_props_get_contact_shadows() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var prop := StaticBody2D.new()
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.texture = PlaceholderTexture2D.new()
	prop.add_child(sprite)
	world.add_child(prop)
	PropShadows.apply(world)
	var shadow := prop.get_node_or_null("ContactShadow")
	assert_not_null(shadow, "props get grounded")
	assert_eq(prop.get_child(0), shadow, "shadow draws under the sprite")
