class_name PropShadows
extends Object
## Soft contact shadows under world props (playtest 2026-06-11: props read
## as stickers without ground contact). Runtime, generic: every StaticBody2D
## with a Sprite2D in the zone's World container gets an ellipse at its base.

const SHADOW_TEX := preload("res://assets/sprites/light/glow_radial.png")
const SHADOW_ALPHA := 0.30
const WIDTH_FACTOR := 0.82
const FLATTEN := 0.34


static func apply(world: Node2D) -> void:
	for body in world.get_children():
		if not body is StaticBody2D:
			continue
		var sprite := body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite == null or sprite.texture == null:
			continue
		var shadow := Sprite2D.new()
		shadow.name = "ContactShadow"
		shadow.texture = SHADOW_TEX
		shadow.modulate = Color(0, 0, 0, SHADOW_ALPHA)
		var width := sprite.texture.get_width() * WIDTH_FACTOR
		var s := width / SHADOW_TEX.get_width()
		shadow.scale = Vector2(s, s * FLATTEN)
		shadow.position = Vector2(0, -1)
		body.add_child(shadow)
		body.move_child(shadow, 0)  # drawn first = under the prop sprite
