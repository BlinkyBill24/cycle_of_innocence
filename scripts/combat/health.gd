class_name Health
extends Node
## Reusable health component for player, companions, and enemies.

signal hp_changed(current: int, max_value: int)
signal damaged(amount: int, source_position: Vector2)
signal died

@export var max_hp: int = 5
@export var invuln_seconds: float = 0.4

var hp: int
var _invuln_until_msec: int = -1


func _ready() -> void:
	hp = max_hp


func is_dead() -> bool:
	return hp <= 0


func is_invulnerable() -> bool:
	return Time.get_ticks_msec() < _invuln_until_msec


## Returns true if damage was applied.
func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO) -> bool:
	if amount <= 0 or is_dead() or is_invulnerable():
		return false
	hp = maxi(hp - amount, 0)
	_invuln_until_msec = Time.get_ticks_msec() + int(invuln_seconds * 1000.0)
	damaged.emit(amount, source_position)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
	return true


func heal(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
	var previous := hp
	hp = mini(hp + amount, max_hp)
	if hp != previous:
		hp_changed.emit(hp, max_hp)


func restore_full() -> void:
	hp = max_hp
	_invuln_until_msec = -1
	hp_changed.emit(hp, max_hp)
