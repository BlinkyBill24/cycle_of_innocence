extends GutTest
## Flute-gate combat half (decision 2026-06-21): bare fists never hurt monsters;
## pre-flute weapons/throws also do not. Post-flute + weapon (or thrown tool) can.

const PC := preload("res://scripts/player/player_controller.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()


# --- pure rules (no scene tree) ---------------------------------------------

func test_monsters_combat_locked_until_flute() -> void:
	assert_false(PC.monsters_combat_unlocked(), "no flute at start")
	PlayerData.set_story_flag(&"flute_found")
	assert_true(PC.monsters_combat_unlocked(), "flute unlocks combat half")


func test_bare_fists_never_armed() -> void:
	PlayerData.set_story_flag(&"flute_found")
	assert_eq(PlayerData.equipped_weapon, &"", "unarmed")
	assert_false(PC.can_armed_attack_hurt_monsters(), "bare fists cannot hurt monsters even post-flute")


func test_weapon_without_flute_is_blocked() -> void:
	PlayerData.equipped_weapon = &"sturdy_stick"
	assert_false(PC.can_armed_attack_hurt_monsters(), "stick pre-flute is a whiff on monsters")


func test_weapon_with_flute_is_allowed() -> void:
	PlayerData.set_story_flag(&"flute_found")
	PlayerData.equipped_weapon = &"sturdy_stick"
	assert_true(PC.can_armed_attack_hurt_monsters(), "stick + flute can wound monsters")


func test_player_hitbox_gate_melee_unarmed_post_flute() -> void:
	PlayerData.set_story_flag(&"flute_found")
	var hb := Hitbox.new()
	hb.faction = &"player"
	assert_false(PC.can_player_hitbox_hurt_monsters(hb), "unarmed melee hitbox is a whiff")
	hb.free()


func test_player_hitbox_gate_pre_flute_even_with_weapon() -> void:
	PlayerData.equipped_weapon = &"sturdy_stick"
	var hb := Hitbox.new()
	hb.faction = &"player"
	assert_false(PC.can_player_hitbox_hurt_monsters(hb), "pre-flute: no player damage to monsters")
	hb.free()


func test_player_hitbox_gate_thrown_post_flute_unarmed() -> void:
	# Loose rocks are tools: post-flute they may hurt even without an equipped stick.
	PlayerData.set_story_flag(&"flute_found")
	var hb := Hitbox.new()
	hb.faction = &"player"
	hb.add_to_group("thrown")
	assert_true(PC.can_player_hitbox_hurt_monsters(hb), "thrown tool post-flute OK while unarmed")
	hb.free()


func test_player_hitbox_gate_thrown_pre_flute_blocked() -> void:
	var hb := Hitbox.new()
	hb.faction = &"player"
	hb.add_to_group("thrown")
	assert_false(PC.can_player_hitbox_hurt_monsters(hb), "pre-flute flee-only: rocks don't hurt monsters")
	hb.free()


# --- physics: Hurtbox respects the gate ------------------------------------

func _boxes() -> Dictionary:
	var health := Health.new()
	health.max_hp = 5
	health.invuln_seconds = 0.0
	add_child_autofree(health)

	var hurtbox := Hurtbox.new()
	hurtbox.faction = &"enemy"
	hurtbox.health = health
	hurtbox.collision_mask = 32
	hurtbox.collision_layer = 0
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = CircleShape2D.new()
	hurtbox.add_child(hurt_shape)
	add_child_autofree(hurtbox)

	var hitbox := Hitbox.new()
	hitbox.faction = &"player"
	hitbox.damage = 2
	hitbox.collision_layer = 32
	hitbox.collision_mask = 0
	var hit_shape := CollisionShape2D.new()
	hit_shape.shape = CircleShape2D.new()
	hitbox.add_child(hit_shape)
	add_child_autofree(hitbox)

	return {"health": health, "hurtbox": hurtbox, "hitbox": hitbox}


func test_physics_pre_flute_player_hit_does_not_damage() -> void:
	var b := _boxes()
	(b["hitbox"] as Hitbox).activate(1.0)
	await wait_physics_frames(3)
	assert_eq((b["health"] as Health).hp, 5, "pre-flute player hitbox is ignored by enemy hurtbox")


func test_physics_unarmed_post_flute_melee_does_not_damage() -> void:
	PlayerData.set_story_flag(&"flute_found")
	var b := _boxes()
	(b["hitbox"] as Hitbox).activate(1.0)
	await wait_physics_frames(3)
	assert_eq((b["health"] as Health).hp, 5, "post-flute bare melee still a whiff")


func test_physics_armed_post_flute_damages() -> void:
	PlayerData.set_story_flag(&"flute_found")
	PlayerData.equipped_weapon = &"sturdy_stick"
	var b := _boxes()
	(b["hitbox"] as Hitbox).activate(1.0)
	await wait_physics_frames(3)
	assert_eq((b["health"] as Health).hp, 3, "stick + flute wounds the monster")
