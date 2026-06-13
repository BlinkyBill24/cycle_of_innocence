class_name GatedDoor
extends StaticBody2D
## The one diegetic gate of the Hollow House (docs/design/hollow-house-quest.md):
## a stuck door that blocks the inner room until Briar scratches/digs it open —
## i.e. until its paired DiggableSpot is revealed (by Briar's dig OR the no-Briar
## fallback). One gate, not a key-hunt. Decoupled via GameEvents.

## The DiggableSpot whose reveal opens this door (its spot_id).
@export var key_spot_id: StringName = &"hollow_door_scratch"
@export var open := false


func _ready() -> void:
	GameEvents.diggable_revealed.connect(_on_diggable_revealed)
	if open:
		_open()


func _on_diggable_revealed(spot_id: StringName) -> void:
	if spot_id == key_spot_id:
		_open()


func _open() -> void:
	open = true
	for child in get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).set_deferred("disabled", true)
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.25)  # the way is clear
