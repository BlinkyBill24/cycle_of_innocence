class_name DiggableSpot
extends Area2D
## Soft-earth spot Briar can dig up (companion-gated exploration per
## docs/design/game-features.md §7). A dig with a lore payload writes a
## witnessed entry to the Journal (docs/design/secrets-and-discovery.md #1).

@export var spot_id: StringName = &"playground_buried_toy"
## Dig-to-lore payload. When set, the first reveal writes an observed-sign
## entry to the Journal — the dig is a WITNESSED world change, so it earns a
## memory, not a checklist tick. Leave empty for purely mechanical dig spots.
@export_multiline var lore_text: String = ""
## Optional distinct id for the journal entry; defaults to spot_id so each
## spot writes at most one lore entry, idempotently.
@export var lore_sign_id: StringName = &""

var revealed := false


func _ready() -> void:
	add_to_group("diggable")


## Returns true only on the first reveal (assist rewards key off this).
func reveal() -> bool:
	if revealed:
		return false
	revealed = true
	PlayerData.set_story_flag(StringName("dug_" + String(spot_id)))
	if not lore_text.is_empty():
		var sign_id := lore_sign_id if lore_sign_id != &"" else spot_id
		Journal.witness(sign_id, lore_text, Journal.Kind.LORE)
	if GameEvents:
		GameEvents.diggable_revealed.emit(spot_id)
	var marker := get_node_or_null("Marker") as CanvasItem
	if marker:
		marker.modulate = Color(0.5, 0.35, 0.2, 0.5)  # dug-up earth
	return true
