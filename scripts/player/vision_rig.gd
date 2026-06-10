class_name VisionRig
extends Node2D
## Player perception lights (docs/mechanics/vision-and-darkness.md):
## a forward cone that follows facing + a small 360° ambient glow.
## Dread shrinks the ambient radius; the dark outside is the horror.

@export var expanded_vision := false  # accessibility: wider, brighter

const CONE_BASE_SCALE := 2.4
const AMBIENT_BASE_SCALE := 0.9
const AMBIENT_MIN_FACTOR := 0.55  # at terror-level dread
const TURN_SPEED := 7.0  # rad/s toward facing

@onready var cone: PointLight2D = $ConeLight
@onready var ambient: PointLight2D = $AmbientLight

var _player: PlayerController


func _ready() -> void:
	_player = get_parent() as PlayerController
	if expanded_vision:
		cone.texture_scale = CONE_BASE_SCALE * 1.35
		cone.energy *= 1.2


func _process(delta: float) -> void:
	if _player == null:
		return
	var target := _player.get_facing().angle()
	cone.rotation = lerp_angle(cone.rotation, target, minf(TURN_SPEED * delta, 1.0))
	# dread closes the world in: ambient glow shrinks toward its minimum
	var dread01 := DreadManager.get_presentation_strength()
	var factor := lerpf(1.0, AMBIENT_MIN_FACTOR, dread01)
	if expanded_vision:
		factor = maxf(factor, 0.85)
	ambient.texture_scale = AMBIENT_BASE_SCALE * factor
