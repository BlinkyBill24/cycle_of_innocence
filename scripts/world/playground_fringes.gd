class_name PlaygroundFringesZone
extends ZoneRoot
## The vertical-slice zone: village playground (dusk, west) bleeding into the
## forest fringes (cold, east — dread area). Ground is painted procedurally
## from a seeded RNG so the layout is stable run-to-run; real tile art can
## replace the atlas without touching this script.

## Wang terrain painting (zone art pass 2026-06-11): terrains live on cell
## CORNERS (vertices); each cell resolves to a transition tile from one of
## four 4x4 PixelLab atlases. Atlas slot = corner bitmask NW<<3|NE<<2|SW<<1|SE
## with upper=1 (tools/pixellab_tilesets.py download ordering).
enum Terrain { WARM, COLD, FLOOR, PATH, SAND }

const SRC_PLAYGROUND := 0  # warm grass -> trampled path
const SRC_FRINGES := 1     # cold grass -> dead forest floor
const SRC_RITUAL := 2      # warm grass -> ritual sand
const SRC_BLEND := 3       # warm grass -> cold grass (the fringe seam)

## (lower, upper) -> atlas source; pure terrains use lower of a canonical pair
const PAIR_SOURCES := {
	Vector2i(Terrain.WARM, Terrain.PATH): SRC_PLAYGROUND,
	Vector2i(Terrain.WARM, Terrain.SAND): SRC_RITUAL,
	Vector2i(Terrain.WARM, Terrain.COLD): SRC_BLEND,
	Vector2i(Terrain.COLD, Terrain.FLOOR): SRC_FRINGES,
}

## The trampled path peters out where the village's reach ends (vertices
## east of this are never PATH) — keeps a 2-vertex gap to the fringe seam.
const PATH_END_X := -1
const SAND_RECT := Rect2i(-14, -8, 6, 4)  # vertex-space, inclusive ranges

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
	# into the y-sorted container so it layers with props like everyone else
	var world := get_node_or_null("World")
	(world if world else self).add_child(child)


func _on_time_changed(_time: int, _day: int) -> void:
	create_tween().tween_property(tint, "color", WorldState.palette(), 3.0)


func _paint_ground() -> void:
	for y in range(-HEIGHT / 2, HEIGHT / 2):
		for x in range(-WIDTH / 2, WIDTH / 2):
			var pick: Array = cell_tile(x, y)
			ground.set_cell(Vector2i(x, y), pick[0], pick[1])


## Deterministic terrain field sampled at cell corners (vertex space).
## Layout mirrors the old map: path west-east (dying at the fringe), ritual
## sandbox NW, cold fringes east with dead-floor blobs deeper in.
static func vertex_terrain(vx: int, vy: int) -> Terrain:
	if vx <= PATH_END_X and absi(vy - path_wobble(vx)) <= 1:
		return Terrain.PATH
	if vx >= SAND_RECT.position.x and vx < SAND_RECT.position.x + SAND_RECT.size.x \
			and vy >= SAND_RECT.position.y and vy < SAND_RECT.position.y + SAND_RECT.size.y:
		return Terrain.SAND
	var edge := fringe_edge(vy)
	if vx >= edge:
		if vx >= edge + 5 and _blob_noise(vx, vy):
			return Terrain.FLOOR
		return Terrain.COLD
	return Terrain.WARM


## Deterministic smoothed value noise: irregular dead-floor patches with
## wobbly edges (sin*cos gave periodic crosses; raw block-hash gave 90-degree
## slabs). Mirrored in tools/preview_zone_map.py — keep in sync.
static func _blob_noise(vx: int, vy: int) -> bool:
	return _value_noise(vx / 3.0, vy / 3.0) > 0.60


static func _value_noise(x: float, y: float) -> float:
	var x0 := floori(x)
	var y0 := floori(y)
	var fx := smoothstep(0.0, 1.0, x - x0)
	var fy := smoothstep(0.0, 1.0, y - y0)
	var top := lerpf(_hash01(x0, y0), _hash01(x0 + 1, y0), fx)
	var bottom := lerpf(_hash01(x0, y0 + 1), _hash01(x0 + 1, y0 + 1), fx)
	return lerpf(top, bottom, fy)


static func _hash01(ix: int, iy: int) -> float:
	var h := ((ix * 73856093) ^ (iy * 19349663)) & 0x7fffffff
	return float(h % 1000) / 999.0


## Cell -> [atlas_source, atlas_coords]; pure, unit-tested.
static func cell_tile(x: int, y: int) -> Array:
	return wang_tile(vertex_terrain(x, y), vertex_terrain(x + 1, y),
			vertex_terrain(x, y + 1), vertex_terrain(x + 1, y + 1))


## Resolve 4 corner terrains to a Wang tile. Unknown mixes (never produced
## by vertex_terrain — asserted in tests) fall back to the NW corner's pure
## tile so a future layout bug shows as wrong ground, not a crash.
static func wang_tile(nw: Terrain, ne: Terrain, sw: Terrain, se: Terrain) -> Array:
	var corners: Array[Terrain] = [nw, ne, sw, se]
	var kinds := {}
	for t in corners:
		kinds[t] = true
	if kinds.size() == 1:
		return _pure_tile(nw)
	if kinds.size() == 2:
		for pair: Vector2i in PAIR_SOURCES:
			if kinds.has(pair.x) and kinds.has(pair.y):
				var idx := 0
				for i in corners.size():
					idx = idx << 1 | (1 if corners[i] == pair.y else 0)
				return [PAIR_SOURCES[pair], Vector2i(idx % 4, idx / 4)]
	return _pure_tile(nw)


static func _pure_tile(terrain: Terrain) -> Array:
	match terrain:
		Terrain.PATH:
			return [SRC_PLAYGROUND, Vector2i(3, 3)]  # idx 15: all-upper
		Terrain.SAND:
			return [SRC_RITUAL, Vector2i(3, 3)]
		Terrain.COLD:
			return [SRC_FRINGES, Vector2i(0, 0)]  # idx 0: all-lower
		Terrain.FLOOR:
			return [SRC_FRINGES, Vector2i(3, 3)]
		_:
			return [SRC_PLAYGROUND, Vector2i(0, 0)]


static func path_wobble(x: int) -> int:
	return int(round(sin(float(x) * 0.35) * 2.0))


## Fringe boundary wobbles between vertex x 1 and 5 — east of it the world
## goes cold. PATH_END_X keeps the path two vertices clear of the minimum.
static func fringe_edge(vy: int) -> int:
	return 3 + int(round(2.0 * sin(float(vy) * 0.45)))
