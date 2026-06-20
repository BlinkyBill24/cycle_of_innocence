extends GutTest
## Pick-up-throw verb: lift -> carry -> hurl with a FAKED arc (no physics gravity),
## emitting pick-up/throw/land on the bus, and damaging a monster through the SAME
## player-faction Hitbox path the slingshot uses (one combat system).

const ThrowableScene := preload("res://scenes/world/throwable_object.tscn")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func _make_throwable() -> ThrowableObject:
	var obj: ThrowableObject = ThrowableScene.instantiate()
	add_child_autofree(obj)
	return obj


func _carrier_at(pos: Vector2) -> Node2D:
	var c := Node2D.new()
	add_child_autofree(c)
	c.global_position = pos
	return c


func test_pickup_sets_carried_state() -> void:
	var obj := _make_throwable()
	await wait_physics_frames(1)
	assert_true(obj.is_available(), "a resting object can be lifted")
	watch_signals(GameEvents)
	obj.pick_up(_carrier_at(Vector2.ZERO))
	assert_eq(obj.state, ThrowableObject.State.CARRIED, "lifting sets the carried state")
	assert_false(obj.is_available(), "a carried object can't be lifted again")
	assert_signal_emitted(GameEvents, "throwable_picked_up")


func test_throw_travels_in_facing_dir_and_lands() -> void:
	var obj := _make_throwable()
	var carrier := _carrier_at(Vector2.ZERO)
	await wait_physics_frames(1)
	obj.pick_up(carrier)
	await wait_physics_frames(1)  # settle onto the carry position
	var x0 := obj.global_position.x
	obj.throw_in_dir(Vector2.RIGHT)
	await wait_physics_frames(40)  # > throw_time
	assert_gt(obj.global_position.x, x0 + 50.0, "it travels in the facing direction")
	assert_eq(obj.state, ThrowableObject.State.LANDED, "and comes to rest on landing")


func test_landing_emits_the_land_event() -> void:
	var obj := _make_throwable()
	await wait_physics_frames(1)
	obj.pick_up(_carrier_at(Vector2.ZERO))
	watch_signals(GameEvents)
	obj.throw_in_dir(Vector2.RIGHT)
	await wait_physics_frames(40)
	assert_signal_emitted(GameEvents, "throwable_thrown")
	assert_signal_emitted(GameEvents, "throwable_landed")


func test_thrown_object_hits_a_monster_via_the_shared_hitpath() -> void:
	# an enemy-faction Hurtbox + Health sitting on the flight line
	var health := Health.new()
	health.max_hp = 5
	health.invuln_seconds = 0.0
	add_child_autofree(health)
	var hurt := Hurtbox.new()
	hurt.faction = &"enemy"
	hurt.health = health
	hurt.collision_mask = 32
	hurt.collision_layer = 0
	var hshape := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 14.0
	hshape.shape = circ
	hurt.add_child(hshape)
	add_child_autofree(hurt)
	hurt.global_position = Vector2(60, -14)  # carried y is -14, flight keeps it

	var obj := _make_throwable()
	var carrier := _carrier_at(Vector2.ZERO)
	await wait_physics_frames(1)
	obj.pick_up(carrier)            # carried pos -> (0, -14)
	await wait_physics_frames(1)
	obj.throw_in_dir(Vector2.RIGHT)  # flies through (60, -14)
	await wait_physics_frames(40)
	assert_eq(health.hp, 4, "a thrown object deals exactly ONE hit via the shared Hitbox/Faction path")
