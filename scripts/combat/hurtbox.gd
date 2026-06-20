class_name Hurtbox
extends Area2D
## Damage-receiving area. Routes enemy-faction hitbox contacts to a Health
## component and reports hits globally (hitstop + HUD listeners).

signal hit_received(hitbox: Hitbox)

@export var faction: StringName = &"player"
@export var health: Health


func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hitbox := area as Hitbox
	if hitbox == null:
		return
	# never wound your own body — a hitbox and hurtbox on the SAME character don't
	# interact, whatever their factions (a Dominated thrall's ally attack must not
	# bite the thrall, whose hurtbox is still the enemy faction).
	var mine := _character(self)
	if mine != null and mine == _character(hitbox):
		return
	if not Faction.hostile(hitbox.faction, faction):
		return
	if health == null or not health.take_damage(hitbox.damage, hitbox.global_position):
		return
	hit_received.emit(hitbox)
	if GameEvents:
		GameEvents.combat_hit.emit(faction, hitbox.damage)
	CombatJuice.hitstop(get_tree())


## The CharacterBody2D this box belongs to, or null for free-floating boxes
## (e.g. a thrown projectile parented to the world). Used for self-exclusion.
static func _character(box: Node) -> Node:
	var n := box.get_parent()
	while n != null:
		if n is CharacterBody2D:
			return n
		n = n.get_parent()
	return null
