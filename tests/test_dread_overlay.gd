extends GutTest
## Regression: the dread overlay's shader strength must follow DreadManager
## (playtest 2026-06-10: vignette wiring worked but tuning was invisible —
## this pins the wiring; tuning is judged by eye).


func after_each() -> void:
	DreadManager.reset()


func test_overlay_strength_follows_dread() -> void:
	var overlay: CanvasLayer = load("res://scenes/effects/dread_overlay.tscn").instantiate()
	add_child_autofree(overlay)
	await wait_physics_frames(2)
	var rect: ColorRect = overlay.get_node("VignetteRect")
	var mat := rect.material as ShaderMaterial
	assert_not_null(mat, "overlay rect has shader material")
	DreadManager.add_dread(90.0)
	await wait_seconds(1.5)
	var strength: float = mat.get_shader_parameter("strength")
	assert_gt(strength, 0.4, "shader strength rises toward dread presentation level")
	DreadManager.set_horror_intensity(0.0)
	await wait_seconds(1.5)
	strength = mat.get_shader_parameter("strength")
	assert_lt(strength, 0.1, "horror intensity 0 mutes presentation")
	DreadManager.set_horror_intensity(1.0)
