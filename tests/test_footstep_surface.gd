extends GutTest
## Per-surface footsteps (rough): gravel/path/sand → the gravel sample, every
## other surface → grass. Plus the SurfaceZone overlap flag.

const PC := preload("res://scripts/player/player_controller.gd")
const SurfaceZoneScript := preload("res://scripts/world/surface_zone.gd")


func test_footstep_sound_maps_hard_surfaces_to_gravel() -> void:
	assert_eq(PC.footstep_sound(&"gravel"), &"footstep_gravel")
	assert_eq(PC.footstep_sound(&"path"), &"footstep_gravel")
	assert_eq(PC.footstep_sound(&"sand"), &"footstep_gravel")


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
