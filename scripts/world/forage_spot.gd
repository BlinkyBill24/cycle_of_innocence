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
## Persistent one-shot key, set when foraged so the pickup NEVER reappears across
## save/load or zone re-entry (playtest 2026-06-21: re-entering re-foraged the
## slingshot/stones into duplicate slots). Empty -> derived from the node name,
## which is unique per scene. Persists via PlayerData story flags / SaveManager.
@export var once_flag: StringName = &""

var granted := false


func _ready() -> void:
	add_to_group("forage_spot")
	monitoring = true
	collision_mask = 2  # player body layer (matches ZoneTransition)
	body_entered.connect(_on_body_entered)
	if _already_taken():
		_mark_taken()


## The persistent flag for THIS spot (override, else "foraged_<node name>").
func _persist_key() -> StringName:
	return once_flag if once_flag != &"" else StringName("foraged_" + String(name))


## Already foraged before (a saved one-shot), or a gate item already acquired.
func _already_taken() -> bool:
	if PlayerData.has_story_flag(_persist_key()):
		return true
	var def := ItemRegistry.get_def(item_id)
	return def != null and def.grants_flag != &"" and PlayerData.has_story_flag(def.grants_flag)


func _mark_taken() -> void:
	granted = true
	monitoring = false
	var marker := get_node_or_null("Marker") as CanvasItem
	if marker:
		marker.visible = false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		grant()


## Grants the item once (ever). Returns true only on the first successful grant — a
## full satchel leaves the spot available so the pickup is never silently lost.
func grant() -> bool:
	if granted or _already_taken():
		return false
	if not Inventory.add(item_id, quantity):
		return false  # e.g. satchel full — try again after making room
	PlayerData.set_story_flag(_persist_key())  # one-shot: never re-grant on revisit
	_mark_taken()
	return true
