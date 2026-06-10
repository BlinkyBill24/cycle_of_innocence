extends GutTest
## Playtest-fix regressions: soothing must visibly affect the monster.

var enemy: EnemyBase


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()
	enemy = load("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func test_soothing_holds_back_the_lunge() -> void:
	enemy.add_recognition(10.0)
	assert_gt(enemy._soothe_hold, 0.0, "active soothing sets the hesitation window")


func test_soothe_hold_decays() -> void:
	enemy.add_recognition(10.0)
	enemy._physics_process(1.0)
	assert_eq(enemy._soothe_hold, 0.0, "hesitation fades when the song stops")


func test_recognition_tints_toward_calm() -> void:
	enemy._physics_process(0.016)
	var base := enemy.sprite.modulate
	enemy.add_recognition(80.0)
	enemy._physics_process(0.016)
	assert_gt(enemy.sprite.modulate.b, base.b, "creature pales toward calm as recognition grows")
