extends GutTest
## Hitbox/Hurtbox physics interaction: faction filtering + damage routing.

var health: Health
var hurtbox: Hurtbox
var hitbox: Hitbox


func before_each() -> void:
	health = Health.new()
	health.max_hp = 5
	health.invuln_seconds = 0.0
	add_child_autofree(health)

	hurtbox = Hurtbox.new()
	hurtbox.faction = &"enemy"
	hurtbox.health = health
	hurtbox.collision_mask = 32
	hurtbox.collision_layer = 0
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = CircleShape2D.new()
	hurtbox.add_child(hurt_shape)
	add_child_autofree(hurtbox)

	hitbox = Hitbox.new()
	hitbox.faction = &"player"
	hitbox.damage = 2
	hitbox.collision_layer = 32
	hitbox.collision_mask = 0
	var hit_shape := CollisionShape2D.new()
	hit_shape.shape = CircleShape2D.new()
	hitbox.add_child(hit_shape)
	add_child_autofree(hitbox)


func _let_physics_settle() -> void:
	await wait_physics_frames(3)


func test_active_hitbox_damages_other_faction() -> void:
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 3, "overlapping active hitbox applies damage")


func test_inactive_hitbox_does_nothing() -> void:
	await _let_physics_settle()
	assert_eq(health.hp, 5, "disabled hitbox shape must not damage")


func test_same_faction_is_ignored() -> void:
	hitbox.faction = &"enemy"
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 5, "friendly fire blocked by faction check")


# --- faction-aware hitboxes (Dominated thrall plumbing) -------------------
# Default setup is a hitbox over an enemy-faction hurtbox.

func test_ally_thrall_attack_damages_an_enemy() -> void:
	hitbox.faction = &"ally"  # a Dominated thrall's lunge
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 3, "the thrall wounds an enemy monster")


func test_ally_thrall_attack_does_not_damage_the_player() -> void:
	hurtbox.faction = &"player"
	hitbox.faction = &"ally"
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 5, "the thrall never bites Rowan")


func test_player_attack_still_damages_an_enemy() -> void:
	# regression: hitbox defaults to player faction, hurtbox to enemy
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 3, "Rowan still hurts enemies")


func test_enemy_attack_still_damages_the_player() -> void:
	# regression
	hurtbox.faction = &"player"
	hitbox.faction = &"enemy"
	hitbox.activate(1.0)
	await _let_physics_settle()
	assert_eq(health.hp, 3, "a normal monster still hurts Rowan")


func test_same_character_boxes_never_self_damage() -> void:
	# A hostile pair (ally hitbox vs enemy hurtbox) on ONE body must not interact —
	# this is what keeps a thrall's ally lunge from wounding its own enemy hurtbox.
	var body := CharacterBody2D.new()
	add_child_autofree(body)

	var self_health := Health.new()
	self_health.max_hp = 5
	self_health.invuln_seconds = 0.0
	body.add_child(self_health)

	var self_hurt := Hurtbox.new()
	self_hurt.faction = &"enemy"
	self_hurt.health = self_health
	self_hurt.collision_mask = 32
	self_hurt.collision_layer = 0
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = CircleShape2D.new()
	self_hurt.add_child(hurt_shape)
	body.add_child(self_hurt)

	var self_hit := Hitbox.new()
	self_hit.faction = &"ally"
	self_hit.damage = 2
	self_hit.collision_layer = 32
	self_hit.collision_mask = 0
	var hit_shape := CollisionShape2D.new()
	hit_shape.shape = CircleShape2D.new()
	self_hit.add_child(hit_shape)
	body.add_child(self_hit)

	self_hit.activate(1.0)
	await _let_physics_settle()
	assert_eq(self_health.hp, 5, "a box never wounds a hurtbox on its own character")
