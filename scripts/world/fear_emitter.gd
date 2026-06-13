class_name FearEmitter
extends Node2D
## Proximity "fear emitter" (docs/mechanics/adaptive-audio.md fear-emitter hook,
## Dead Space model): drives the EXISTING DreadManager by closeness to a target
## (the hidden truth), so dread — and thus the danger stem — rises as the player
## nears it. A wiring node that uses only DreadManager.add_dread; NOT a new audio
## system or mechanic. See [[mechanics/adaptive-audio]] · [[design/hollow-house-quest]].

## What to fear (the book). Empty = this node's own position.
@export var target_path: NodePath
@export var radius: float = 150.0      # full effect at the target, none past this
@export var max_rate: float = 26.0     # dread/sec added when standing on the target
@export var active := true

var _target: Node2D


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node2D
	if _target == null:
		_target = self


func _process(delta: float) -> void:
	if not active or _target == null:
		return
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var dist := player.global_position.distance_to(_target.global_position)
	if dist >= radius:
		return
	# continuous add near the truth overcomes DreadManager's decay → a ramp
	DreadManager.add_dread(max_rate * proximity_curve(dist, radius) * delta, &"fear_emitter")


## Pure, testable: 1.0 at the target, 0.0 at the radius edge, eased so dread
## ramps sharply only when the player is close to the hidden truth.
static func proximity_curve(dist: float, radius: float) -> float:
	if radius <= 0.0:
		return 0.0
	var t := clampf(1.0 - dist / radius, 0.0, 1.0)
	return t * t
