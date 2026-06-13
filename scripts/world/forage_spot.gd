class_name ForageSpot
extends Area2D
## One-shot world pickup that grants an inventory item the first time the player
## walks over it (vertical-slice demo of the inventory grant path). Self-contained:
## touches only Inventory.add — no edits to PlayerData / GameEvents / the UI panel.
##
## Demo wiring: place one of these in playground_fringes granting &"dried_meat"
## after the escape beat. The player then opens the Satchel (I) and feeds Briar.

## Item id to grant — must match a resources/items/<id>.tres stem.
@export var item_id: StringName = &"dried_meat"
@export var quantity: int = 1

var granted := false


func _ready() -> void:
	add_to_group("forage_spot")
	monitoring = true
	collision_mask = 2  # player body layer (matches ZoneTransition)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		grant()


## Grants the item once. Returns true only on the first successful grant — a full
## satchel leaves the spot available so the pickup is never silently lost.
func grant() -> bool:
	if granted:
		return false
	if not Inventory.add(item_id, quantity):
		return false  # e.g. satchel full — try again after making room
	granted = true
	var marker := get_node_or_null("Marker") as CanvasItem
	if marker:
		marker.visible = false
	return true
