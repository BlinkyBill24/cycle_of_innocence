class_name PlaygroundFringesZone
extends ZoneRoot
## The vertical-slice zone: village playground (dusk, west) bleeding into the
## forest fringes (cold, east — dread area). Ground is painted procedurally
## from a seeded RNG so the layout is stable run-to-run; real tile art can
## replace the atlas without touching this script.

const TILE_GRASS_WARM := Vector2i(0, 0)
const TILE_PATH := Vector2i(1, 0)
const TILE_GRASS_COLD := Vector2i(2, 0)
const TILE_FOREST := Vector2i(3, 0)
const TILE_SAND := Vector2i(4, 0)

## Zone footprint in tiles (centered on origin): x in [-W/2, W/2)
const WIDTH := 44
const HEIGHT := 26

const TWISTED_CHILD := preload("res://scenes/enemies/twisted_child.tscn")
const EMERGENCY_SPAWN := Vector2(640, 250)  # deep fringes, east

@onready var ground: TileMapLayer = $Ground
@onready var tint: CanvasModulate = $DuskTint

var _emergency_spawned := false


func _ready() -> void:
	super._ready()
	_paint_ground()
	tint.color = WorldState.palette()
	WorldState.time_changed.connect(_on_time_changed)
	GameEvents.hollowing_stage_advanced.connect(_on_hollowing_advanced)
	if HollowingClock.stage >= HollowingClock.Stage.ALARM:
		_spawn_emergency_child()


func _on_hollowing_advanced(stage: int) -> void:
	if stage >= HollowingClock.Stage.ALARM:
		_spawn_emergency_child()


## Stage 2 consequence (hollowing-clock.md): the first emergency ritual — a
## new monster the player could not save. Not spareable; the cost of delay.
func _spawn_emergency_child() -> void:
	if _emergency_spawned:
		return
	_emergency_spawned = true
	var child: EnemyBase = TWISTED_CHILD.instantiate()
	child.stable_id = &"emergency_child_01"
	child.spareable = false
	child.position = EMERGENCY_SPAWN
	child.modulate = Color(0.72, 0.66, 0.78)  # already further gone
	add_child(child)


func _on_time_changed(_time: int, _day: int) -> void:
	create_tween().tween_property(tint, "color", WorldState.palette(), 3.0)


func _paint_ground() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260610  # deterministic layout
	for y in range(-HEIGHT / 2, HEIGHT / 2):
		for x in range(-WIDTH / 2, WIDTH / 2):
			ground.set_cell(Vector2i(x, y), 0, _tile_for(x, y, rng))


func _tile_for(x: int, y: int, rng: RandomNumberGenerator) -> Vector2i:
	# Ritual sandbox: small patch near the playground center.
	if x >= -14 and x <= -9 and y >= -3 and y <= 1:
		return TILE_SAND
	# Trampled path running west-east through the middle (the escape route).
	if absi(y - _path_wobble(x)) <= 1:
		return TILE_PATH
	# West = playground at dusk, east = fringes; noisy blend across the seam.
	var fringe_chance := clampf(inverse_lerp(-6.0, 10.0, float(x)), 0.0, 1.0)
	if rng.randf() < fringe_chance:
		return TILE_FOREST if rng.randf() < 0.35 else TILE_GRASS_COLD
	return TILE_GRASS_WARM


func _path_wobble(x: int) -> int:
	return int(round(sin(float(x) * 0.35) * 2.0))
