class_name DiggableSpot
extends Area2D
## Soft-earth spot Briar can dig up (companion-gated exploration per
## docs/design/game-features.md §7). Reveal payloads grow in M2 (memory
## fragments -> journal); v1 emits the global signal and changes visuals.

@export var spot_id: StringName = &"playground_buried_toy"

var revealed := false


func _ready() -> void:
	add_to_group("diggable")


## Returns true only on the first reveal (assist rewards key off this).
func reveal() -> bool:
	if revealed:
		return false
	revealed = true
	if GameEvents:
		GameEvents.diggable_revealed.emit(spot_id)
	var marker := get_node_or_null("Marker") as CanvasItem
	if marker:
		marker.modulate = Color(0.5, 0.35, 0.2, 0.5)  # dug-up earth
	return true
