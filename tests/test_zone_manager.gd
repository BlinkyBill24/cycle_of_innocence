extends GutTest
## ZoneManager + DreadZone + ZoneTransition wiring.


func after_each() -> void:
	DreadManager.reset()
	ZoneManager.current_zone_id = &""


func test_enter_zone_updates_state_and_player_data() -> void:
	watch_signals(ZoneManager)
	ZoneManager.enter_zone(&"test_zone_a")
	assert_eq(ZoneManager.current_zone_id, &"test_zone_a")
	assert_eq(PlayerData.last_zone_id, &"test_zone_a")
	assert_signal_emitted_with_parameters(ZoneManager, "zone_changed", [&"test_zone_a"])


func test_reentering_same_zone_is_noop() -> void:
	ZoneManager.enter_zone(&"test_zone_a")
	watch_signals(ZoneManager)
	ZoneManager.enter_zone(&"test_zone_a")
	assert_signal_not_emitted(ZoneManager, "zone_changed")


func test_transition_request_emits() -> void:
	watch_signals(ZoneManager)
	ZoneManager.request_transition(&"village_edge")
	assert_signal_emitted_with_parameters(ZoneManager, "transition_requested", [&"village_edge"])


func test_dread_zone_registers_and_reacts_to_player() -> void:
	var dz := DreadZone.new()
	dz.dread_zone_id = &"test_dread_area"
	dz.dread_level = 60.0
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	dz.add_child(shape)
	add_child_autofree(dz)

	var player := CharacterBody2D.new()
	player.add_to_group("player")
	player.collision_layer = 2
	var pshape := CollisionShape2D.new()
	pshape.shape = CircleShape2D.new()
	player.add_child(pshape)
	add_child_autofree(player)
	player.global_position = dz.global_position
	await wait_physics_frames(3)
	# the global DreadManager received both the registration and the entered event
	assert_eq(DreadManager.get_zone_baseline(), 60.0, "registered level applied on player entry")
	player.global_position += Vector2(2000, 0)
	await wait_physics_frames(3)
	assert_eq(DreadManager.get_zone_baseline(), 0.0, "baseline drops on exit")


func test_zone_scene_loads_and_paints_ground() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	assert_eq(ZoneManager.current_zone_id, &"playground_fringes")
	var ground: TileMapLayer = zone.get_node("Ground")
	assert_gt(ground.get_used_cells().size(), 1000, "ground painted procedurally")
