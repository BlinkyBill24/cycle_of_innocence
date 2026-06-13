extends PointLight2D
## Campfire flicker — warm, alive, the visual promise of safety.
## Toned down 2026-06-13: the old energy 1.1 / scale 1.5 bloomed over the new
## animated campfire sprite and washed out the hideout. Exported so it's
## tunable in the editor without touching code.

@export var base_energy := 0.6
@export var base_scale := 0.95

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	energy = base_energy + sin(_t * 7.0) * 0.05 + sin(_t * 13.7) * 0.03
	texture_scale = base_scale + sin(_t * 5.3) * 0.03
