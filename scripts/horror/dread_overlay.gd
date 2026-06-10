extends CanvasLayer
## Drives the dread post-process shader from DreadManager.
## Smooths toward the target so dread creeps in instead of popping.

const SMOOTH_SPEED := 2.0

@onready var _rect: ColorRect = $VignetteRect

var _current_strength := 0.0


func _ready() -> void:
	_apply(DreadManager.get_presentation_strength())


func _process(delta: float) -> void:
	var target := DreadManager.get_presentation_strength()
	if is_equal_approx(_current_strength, target):
		return
	_current_strength = lerpf(_current_strength, target, minf(delta * SMOOTH_SPEED, 1.0))
	_apply(_current_strength)


func _apply(value: float) -> void:
	var mat := _rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("strength", value)
