extends PointLight2D
## Campfire flicker — warm, alive, the visual promise of safety.

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	energy = 1.1 + sin(_t * 7.0) * 0.08 + sin(_t * 13.7) * 0.05
	texture_scale = 1.5 + sin(_t * 5.3) * 0.04
