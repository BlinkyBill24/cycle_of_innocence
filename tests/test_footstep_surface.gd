extends GutTest
## Per-surface footsteps (rough): gravel/path/sand → the gravel sample, every
## other surface → grass. Plus the SurfaceZone overlap flag.

const PC := preload("res://scripts/player/player_controller.gd")
const SurfaceZoneScript := preload("res://scripts/world/surface_zone.gd")


func test_footstep_sound_maps_hard_surfaces_to_gravel() -> void:
	assert_eq(PC.footstep_sound(&"gravel"), &"footstep_gravel")
	assert_eq(PC.footstep_sound(&"path"), &"footstep_gravel")
	assert_eq(PC.footstep_sound(&"sand"), &"footstep_gravel")
	assert_eq(PC.footstep_sound(&"wood"), &"footstep_gravel", "wood reads as the hard step")


func test_playground_authors_path_sand_and_wood_surfaces() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var surfaces := {}
	for node in get_tree().get_nodes_in_group("surface_zone"):
		var sz := node as SurfaceZone
		if sz:
			surfaces[sz.surface] = true
	for expected: StringName in [&"path", &"sand", &"wood"]:
		assert_true(surfaces.has(expected), "the playground authors a %s surface zone" % expected)
	assert_false(surfaces.has(&"grass"), "grass is the default ground, never an authored zone")


func test_footstep_sound_defaults_to_grass() -> void:
	assert_eq(PC.footstep_sound(&"grass"), &"footstep")
	assert_eq(PC.footstep_sound(&"unmapped"), &"footstep", "unknown -> grass")
	assert_eq(PC.footstep_sound(&""), &"footstep")


func test_surface_zone_tracks_player_overlap() -> void:
	var zone: SurfaceZone = SurfaceZoneScript.new()
	zone.surface = &"gravel"
	add_child_autofree(zone)
	assert_false(zone.has_player(), "empty by default")
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	zone._on_body_entered(player)
	assert_true(zone.has_player())
	zone._on_body_exited(player)
	assert_false(zone.has_player())
	# non-player bodies are ignored
	var enemy := CharacterBody2D.new()
	zone._on_body_entered(enemy)
	assert_false(zone.has_player())
