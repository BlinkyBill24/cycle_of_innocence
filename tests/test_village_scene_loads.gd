extends GutTest
## Tester-02 crash repro: walking left to the village crashed the web build.
## At minimum the village scene must instantiate cleanly with autoloads up.

func test_village_scene_instantiates() -> void:
	var ps: PackedScene = load("res://scenes/zones/village_green.tscn")
	assert_not_null(ps, "village scene resource loads")
	var inst: Node = ps.instantiate()
	assert_not_null(inst, "village scene instantiates")
	add_child_autofree(inst)
	await wait_physics_frames(2)
	assert_true(true, "village scene survived 2 physics frames")
