extends GutTest
## Allied-monster glow (diegetic safety read): a fully-soothed (Stilled) creature
## emits a PointLight2D glow; a hostile one stays dark; reverting (betrayal /
## hollowing re-aggro) turns it off; and the glow follows the SAVED stilled state
## across save/load — it's a pure read of `stilled`, never a runtime-only flag.

const MonsterScene := preload("res://scenes/enemies/twisted_child.tscn")


func before_each() -> void:
	PlayerData.reset_to_defaults()
	HollowingClock.reset()
	DreadManager.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	HollowingClock.reset()
	DreadManager.reset()


func _monster() -> EnemyBase:
	var m: EnemyBase = MonsterScene.instantiate()
	add_child_autofree(m)
	return m


func test_hostile_monster_does_not_glow() -> void:
	var m := _monster()
	await wait_physics_frames(1)
	assert_not_null(m.allied_glow, "the monster carries an allied-glow light")
	assert_false(m.allied_glow.enabled, "a hostile monster does not glow")


func test_soothing_to_allied_turns_the_glow_on() -> void:
	var m := _monster()
	await wait_physics_frames(1)
	var newly := m.add_recognition(EnemyBase.RECOGNITION_MAX, true)  # full soothe (with the key)
	assert_true(newly, "reached the fully-soothed (Stilled) state")
	assert_true(m.stilled)
	assert_true(m.allied_glow.enabled, "a soothed, allied creature glows")


func test_betrayal_turns_the_glow_off() -> void:
	var m := _monster()
	await wait_physics_frames(1)
	m.add_recognition(EnemyBase.RECOGNITION_MAX, true)
	assert_true(m.allied_glow.enabled, "glowing while allied")
	m._betrayed()  # struck while stilled — it wakes and defends itself
	assert_false(m.stilled)
	assert_false(m.allied_glow.enabled, "betrayal extinguishes the glow")


func test_hollowing_reaggro_turns_the_glow_off() -> void:
	var m := _monster()
	await wait_physics_frames(1)
	m.add_recognition(EnemyBase.RECOGNITION_MAX, true)
	assert_true(m.allied_glow.enabled)
	m._on_hollowing_advanced(HollowingClock.RE_AGGRO_STAGE)  # the Hunger reasserts
	assert_false(m.stilled)
	assert_false(m.allied_glow.enabled, "the net closing extinguishes the glow")


func test_allied_halo_follows_the_state() -> void:
	# the halo is the always-visible read (the bare PointLight2D was too subtle)
	var m := _monster()
	await wait_physics_frames(1)
	assert_not_null(m.allied_halo, "the monster carries an allied halo")
	assert_false(m.allied_halo.visible, "hostile -> no halo")
	m.add_recognition(EnemyBase.RECOGNITION_MAX, true)
	assert_true(m.allied_halo.visible, "soothed -> the halo shows")
	m._betrayed()
	assert_false(m.allied_halo.visible, "betrayal -> the halo hides")


func test_loaded_stilled_monster_glows_from_saved_state() -> void:
	# the persisted flag (what SaveManager restores) drives the glow on _ready
	PlayerData.set_story_flag(&"stilled_twisted_child_01")
	var m := _monster()
	await wait_physics_frames(1)
	assert_true(m.stilled, "restored from the saved stilled flag")
	assert_true(m.allied_glow.enabled, "a loaded allied monster glows again")


func test_glow_survives_a_real_save_load() -> void:
	var m := _monster()
	await wait_physics_frames(1)
	m.add_recognition(EnemyBase.RECOGNITION_MAX, true)  # become stilled (writes the flag)
	assert_true(SaveManager.save_game(95), "save writes")
	PlayerData.reset_to_defaults()
	assert_true(SaveManager.load_game(95, false), "load reads")
	var reloaded := _monster()  # a fresh monster, instantiated after the load
	await wait_physics_frames(1)
	assert_true(reloaded.stilled, "the allied state came back with the save")
	assert_true(reloaded.allied_glow.enabled, "and so did its glow")
	SaveManager.delete_save(95)
