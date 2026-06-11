class_name PropShadows
extends Object
## Soft contact shadows under world props (playtest 2026-06-11: props read
## as stickers without ground contact). Runtime, generic: every StaticBody2D
## with a Sprite2D in the zone's World container gets an ellipse at its base.

const SHADOW_ALPHA := 0.30
const WIDTH_FACTOR := 0.82
const FLATTEN := 0.34
const TEX_SIZE := 64

## glow_radial.png keeps its gradient in RGB (for Light2D) — modulating it
## black gives a RECTANGLE (playtest 2026-06-11). Build a real alpha-falloff
## ellipse once instead.
static var _shadow_tex: ImageTexture


static func shadow_texture() -> ImageTexture:
	if _shadow_tex:
		return _shadow_tex
	var img := Image.create(TEX_SIZE, TEX_SIZE, false, Image.FORMAT_RGBA8)
	var half := (TEX_SIZE - 1) / 2.0
	for y in TEX_SIZE:
		for x in TEX_SIZE:
			var d := Vector2(x - half, y - half).length() / half
			var alpha := clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(0, 0, 0, alpha * alpha))
	_shadow_tex = ImageTexture.create_from_image(img)
	return _shadow_tex


static func apply(world: Node2D) -> void:
	for body in world.get_children():
		if not body is StaticBody2D:
			continue
		var sprite := body.get_node_or_null("Sprite2D") as Sprite2D
		if sprite == null or sprite.texture == null:
			continue
		var shadow := Sprite2D.new()
		shadow.name = "ContactShadow"
		shadow.texture = shadow_texture()
		shadow.modulate = Color(1, 1, 1, SHADOW_ALPHA)
		var width := sprite.texture.get_width() * WIDTH_FACTOR
		var s := width / float(TEX_SIZE)
		shadow.scale = Vector2(s, s * FLATTEN)
		shadow.position = Vector2(0, -1)
		body.add_child(shadow)
		body.move_child(shadow, 0)  # drawn first = under the prop sprite
