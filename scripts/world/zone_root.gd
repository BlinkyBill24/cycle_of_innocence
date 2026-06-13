class_name ZoneRoot
extends Node2D
## Base for zone scenes: registers itself with ZoneManager on ready, places
## the player at the entry point matching the previous zone, and clamps the
## player camera to the painted ground backdrop so the void past the world
## edge can never show (docs/art/prop-coherence.md fix plan item 2).

## Grace pixels beyond the painted backdrop before the camera stops.
const CAMERA_BLEED := 16.0
## Godot's own Camera2D limit default — used to reset when a zone has no
## backdrop, so limits from the previous zone never leak across a transition.
const LIMIT_OFF := 10000000

@export var zone_id: StringName = &"unnamed_zone"


func _ready() -> void:
	# record the live scene path so saves reload THIS scene (incl. interiors),
	# not just whatever booted (accessible-interiors).
	if not scene_file_path.is_empty():
		ZoneManager.current_scene_path = scene_file_path
	ZoneManager.enter_zone(zone_id)
	ZoneManager.place_player_at_entry.call_deferred(self)
	_clamp_camera_to_backdrop.call_deferred()


## World-space rect a Sprite2D covers (no rotation — backdrops never rotate).
static func sprite_world_rect(
	tex_size: Vector2, pos: Vector2, scl: Vector2, off: Vector2, centered: bool
) -> Rect2:
	var local_top_left := off
	if centered:
		local_top_left -= tex_size / 2.0
	return Rect2(pos + local_top_left * scl, tex_size * scl)


## Camera limits for a backdrop rect, with bleed margin, as
## {left, top, right, bottom} ints (Camera2D limits are int pixels).
static func camera_limits(rect: Rect2, bleed: float) -> Dictionary:
	return {
		"left": int(floor(rect.position.x - bleed)),
		"top": int(floor(rect.position.y - bleed)),
		"right": int(ceil(rect.end.x + bleed)),
		"bottom": int(ceil(rect.end.y + bleed)),
	}


func _clamp_camera_to_backdrop() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	var backdrop := get_node_or_null("GroundBackdrop") as Sprite2D
	if backdrop == null or backdrop.texture == null:
		camera.limit_left = -LIMIT_OFF
		camera.limit_top = -LIMIT_OFF
		camera.limit_right = LIMIT_OFF
		camera.limit_bottom = LIMIT_OFF
		return
	var rect := sprite_world_rect(
		Vector2(backdrop.texture.get_size()),
		backdrop.position,
		backdrop.scale,
		backdrop.offset,
		backdrop.centered
	)
	var limits: Dictionary = camera_limits(rect, CAMERA_BLEED)
	camera.limit_left = int(limits["left"])
	camera.limit_top = int(limits["top"])
	camera.limit_right = int(limits["right"])
	camera.limit_bottom = int(limits["bottom"])
	camera.reset_smoothing()
