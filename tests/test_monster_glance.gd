extends GutTest
## Monster-glance cue (Wiring & Audibility pass, nice-to-have): when the generic
## lullaby stalls at the plateau (no key yet), the child briefly turns toward its
## buried key — a wordless "look there", no UI. Pure rule is unit-tested; the brief
## turn is driven through _update_glance.


func test_should_glance_rule() -> void:
	var P := EnemyBase.GENERIC_PLATEAU
	assert_true(EnemyBase.should_glance_at_secret(P, P, false, false, true),
		"stalled at the plateau, no key, a secret to point at -> glance")
	assert_false(EnemyBase.should_glance_at_secret(P, P, false, true, true),
		"with the key there is no stall -> no glance")
	assert_false(EnemyBase.should_glance_at_secret(P, P, true, false, true),
		"already Stilled -> no glance")
	assert_false(EnemyBase.should_glance_at_secret(P, P, false, false, false),
		"no secret spot -> nothing to point at")
	assert_false(EnemyBase.should_glance_at_secret(P - 10.0, P, false, false, true),
		"below the plateau -> not stalled yet")


func test_stalled_monster_turns_toward_its_key() -> void:
	PlayerData.reset_to_defaults()  # no soothe key held
	var enemy: EnemyBase = preload("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)
	enemy.global_position = Vector2.ZERO
	var spot := Node2D.new()
	spot.position = Vector2(100, 0)  # due east of the monster
	enemy.add_child(spot)
	enemy.secret_spot_path = enemy.get_path_to(spot)
	enemy.recognition = EnemyBase.GENERIC_PLATEAU  # stalled at the plateau
	enemy._soothe_hold = 0.6                        # actively being soothed
	enemy._update_glance(0.0)  # starts the glance window
	enemy._update_glance(0.1)  # aims facing toward the key
	assert_gt(enemy._facing.x, 0.5, "the child turns east, toward its buried key")
