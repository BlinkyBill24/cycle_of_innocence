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
