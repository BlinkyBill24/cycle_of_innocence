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
	if hitbox == null or hitbox.faction == faction:
		return
	if health == null or not health.take_damage(hitbox.damage, hitbox.global_position):
		return
	hit_received.emit(hitbox)
	if GameEvents:
		GameEvents.combat_hit.emit(faction, hitbox.damage)
	CombatJuice.hitstop(get_tree())
