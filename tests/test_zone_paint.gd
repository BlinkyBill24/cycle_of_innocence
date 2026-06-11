extends GutTest
## Wang terrain painter (zone art pass 2026-06-11): the vertex field must
## never produce a corner mix that has no transition tileset, across the
## entire zone footprint — that invariant is what keeps the map seam-free.

const Zone := preload("res://scripts/world/playground_fringes.gd")


func test_every_cell_resolves_to_a_paired_tileset() -> void:
	var fallbacks := 0
	for y in range(-Zone.HEIGHT / 2, Zone.HEIGHT / 2):
		for x in range(-Zone.WIDTH / 2, Zone.WIDTH / 2):
			var corners := [
				Zone.vertex_terrain(x, y), Zone.vertex_terrain(x + 1, y),
				Zone.vertex_terrain(x, y + 1), Zone.vertex_terrain(x + 1, y + 1),
			]
			var kinds := {}
			for t: int in corners:
				kinds[t] = true
			if kinds.size() > 2:
				fallbacks += 1
			elif kinds.size() == 2:
				var paired := false
				for pair: Vector2i in Zone.PAIR_SOURCES:
					if kinds.has(pair.x) and kinds.has(pair.y):
						paired = true
				if not paired:
					fallbacks += 1
	assert_eq(fallbacks, 0, "no cell mixes terrains without a transition tileset")


func test_wang_bitmask_matches_atlas_layout() -> void:
	# NW-only upper = bit 3 = idx 8 -> atlas (0, 2); SE-only = idx 1 -> (1, 0)
	var nw_upper: Array = Zone.wang_tile(Zone.Terrain.PATH, Zone.Terrain.WARM,
			Zone.Terrain.WARM, Zone.Terrain.WARM)
	assert_eq(nw_upper, [Zone.SRC_PLAYGROUND, Vector2i(0, 2)])
	var se_upper: Array = Zone.wang_tile(Zone.Terrain.WARM, Zone.Terrain.WARM,
			Zone.Terrain.WARM, Zone.Terrain.SAND)
	assert_eq(se_upper, [Zone.SRC_RITUAL, Vector2i(1, 0)])


func test_pure_terrains_use_canonical_tiles() -> void:
	assert_eq(Zone.wang_tile(Zone.Terrain.WARM, Zone.Terrain.WARM,
			Zone.Terrain.WARM, Zone.Terrain.WARM), [Zone.SRC_PLAYGROUND, Vector2i(0, 0)])
	assert_eq(Zone.wang_tile(Zone.Terrain.FLOOR, Zone.Terrain.FLOOR,
			Zone.Terrain.FLOOR, Zone.Terrain.FLOOR), [Zone.SRC_FRINGES, Vector2i(3, 3)])


func test_generated_tileset_has_every_tile_the_painter_requests() -> void:
	var tile_set: TileSet = load("res://assets/resources/tiles/ground_tileset.tres")
	for src in [Zone.SRC_PLAYGROUND, Zone.SRC_FRINGES, Zone.SRC_RITUAL, Zone.SRC_BLEND]:
		var atlas := tile_set.get_source(src) as TileSetAtlasSource
		assert_not_null(atlas, "source %d exists" % src)
		for y in range(4):
			for x in range(4):
				assert_true(atlas.has_tile(Vector2i(x, y)),
						"source %d tile %d,%d" % [src, x, y])


func test_path_dies_before_the_fringe_seam() -> void:
	# the village path must never touch cold ground (no PATH/COLD tileset)
	for vy in range(-Zone.HEIGHT / 2, Zone.HEIGHT / 2 + 1):
		assert_gte(Zone.fringe_edge(vy), Zone.PATH_END_X + 2,
				"two-vertex gap between path end and fringe edge")