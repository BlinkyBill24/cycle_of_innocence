class_name VillageGreenZone
extends ZoneRoot
## The village at golden hour (village-life.md). Terranigma pass 2026-06-11:
## organic curved lanes with frayed edges, a terraced north rim (cliff
## tileset — the engine's transition-as-elevation bias used as a feature),
## and hash-scattered terrain variation tiles so the ground reads hand-set.

enum Terrain { GREEN, DIRT, TERRACE }

const SRC_GREEN_COBBLE := 0   # lawn -> cobblestone (unused; kept for interiors)
const SRC_GREEN_YARD := 1     # lawn -> packed dirt (paths, yards)
const SRC_TERRACE := 2        # lawn -> raised terrace (cliff transition)
const SRC_GRASS_VAR := 3      # 6x1 strip of grass variation tiles
const SRC_DIRT_VAR := 4       # 4x1 strip of dirt variation tiles

const PAIR_SOURCES := {
	Vector2i(Terrain.GREEN, Terrain.DIRT): SRC_GREEN_YARD,
	Vector2i(Terrain.GREEN, Terrain.TERRACE): SRC_TERRACE,
}

const GRASS_VARIANTS := 6
const DIRT_VARIANTS := 1
const PLAIN_CHANCE := 0.72  # most cells stay plain; variety, not noise

const WIDTH := 44
const HEIGHT := 28

const RING_RADIUS := 7.5
const RING_HALF_WIDTH := 1.0
const LANE_HALF_WIDTH := 1
## North yards sit one row lower than v1 so the terrace rim never touches
## DIRT (no DIRT<->TERRACE tileset exists — asserted zone-wide in tests).
const YARDS: Array[Rect2i] = [
	Rect2i(-16, -10, 6, 4),  # NW — Marta's house
	Rect2i(10, -10, 6, 4),   # NE
	Rect2i(-15, 8, 6, 4),    # SW
	Rect2i(9, 8, 6, 4),      # SE — Pieter's house
]
const CHAPEL_COURT := Rect2i(-2, -13, 5, 4)
const TERRACE_EDGE_Y := -12   # north rim plateau starts here
const TERRACE_GAP_X := 6      # kept clear of the chapel court + north lane

@onready var ground: TileMapLayer = $Ground
@onready var tint: CanvasModulate = $DuskTint


func _ready() -> void:
	super._ready()
	_paint_ground()
	PropShadows.apply($World)
	tint.color = WorldState.palette()
	WorldState.time_changed.connect(func(_t: int, _d: int) -> void:
		create_tween().tween_property(tint, "color", WorldState.palette(), 3.0))


func _paint_ground() -> void:
	for y in range(-HEIGHT / 2, HEIGHT / 2):
		for x in range(-WIDTH / 2, WIDTH / 2):
			var pick: Array = cell_tile(x, y)
			ground.set_cell(Vector2i(x, y), pick[0], pick[1])


## --- terrain field (deterministic; mirrored in tools/preview_village_map.py) ---

static func lane_wobble(vx: int) -> int:
	return int(round(sin(float(vx) * 0.23) * 2.0))


static func north_lane_wobble(vy: int) -> int:
	return int(round(sin(float(vy) * 0.31) * 1.5))


static func _hash01(ix: int, iy: int) -> float:
	var h := ((ix * 73856093) ^ (iy * 19349663)) & 0x7fffffff
	return float(h % 1000) / 999.0


static func vertex_terrain(vx: int, vy: int) -> Terrain:
	# terraced north rim, clear of the chapel court and the north lane
	if vy <= TERRACE_EDGE_Y and absi(vx) >= TERRACE_GAP_X:
		return Terrain.TERRACE
	# frayed jitter: boundaries breathe by up to ~1 vertex
	var jitter := (_hash01(vx, vy) - 0.5) * 0.9
	var dist := sqrt(float(vx * vx + vy * vy))
	if absf(dist - (RING_RADIUS + jitter)) <= RING_HALF_WIDTH:
		return Terrain.DIRT
	if absi(vy - lane_wobble(vx)) <= LANE_HALF_WIDTH \
			or (absi(vy - lane_wobble(vx)) == LANE_HALF_WIDTH + 1 and _hash01(vx, vy) < 0.28):
		return Terrain.DIRT
	if vy < 0 and vy >= -11 and absi(vx - north_lane_wobble(vy)) <= 1:
		return Terrain.DIRT
	if _in_rect(CHAPEL_COURT, vx, vy):
		return Terrain.DIRT
	for yard in YARDS:
		if _in_rect(yard, vx, vy):
			return Terrain.DIRT
	return Terrain.GREEN


static func _in_rect(r: Rect2i, vx: int, vy: int) -> bool:
	return vx >= r.position.x and vx < r.position.x + r.size.x \
			and vy >= r.position.y and vy < r.position.y + r.size.y


## --- cell resolution ---

static func cell_tile(x: int, y: int) -> Array:
	var corners: Array[Terrain] = [
		vertex_terrain(x, y), vertex_terrain(x + 1, y),
		vertex_terrain(x, y + 1), vertex_terrain(x + 1, y + 1),
	]
	if corners.all(func(t: Terrain) -> bool: return t == Terrain.GREEN):
		return green_cell(x, y)
	if corners.all(func(t: Terrain) -> bool: return t == Terrain.DIRT):
		return dirt_cell(x, y)
	return wang_tile(corners[0], corners[1], corners[2], corners[3])


## Transition resolution (pure, unit-tested). Scatter variants are chosen in
## cell_tile; this handles uniform-nonscatter and two-terrain cells.
static func wang_tile(nw: Terrain, ne: Terrain, sw: Terrain, se: Terrain) -> Array:
	var corners: Array[Terrain] = [nw, ne, sw, se]
	var kinds := {}
	for t in corners:
		kinds[t] = true
	if kinds.size() == 1:
		match nw:
			Terrain.DIRT:
				return [SRC_GREEN_YARD, Vector2i(3, 3)]
			Terrain.TERRACE:
				return [SRC_TERRACE, Vector2i(3, 3)]
			_:
				return [SRC_GREEN_YARD, Vector2i(0, 0)]
	for pair: Vector2i in PAIR_SOURCES:
		if kinds.size() == 2 and kinds.has(pair.x) and kinds.has(pair.y):
			var idx := 0
			for i in corners.size():
				idx = idx << 1 | (1 if corners[i] == pair.y else 0)
			return [PAIR_SOURCES[pair], Vector2i(idx % 4, idx / 4)]
	# unknown mix (DIRT+TERRACE etc) — layout must prevent it (tested)
	return [SRC_GREEN_YARD, Vector2i(0, 0)]


## Hash-scattered variation: most cells plain, the rest hand-set details.
static func green_cell(x: int, y: int) -> Array:
	var h := _hash01(x * 3 + 11, y * 5 + 7)
	if h < PLAIN_CHANCE:
		return [SRC_GREEN_YARD, Vector2i(0, 0)]
	var variant := int((h - PLAIN_CHANCE) / (1.0 - PLAIN_CHANCE) * GRASS_VARIANTS)
	return [SRC_GRASS_VAR, Vector2i(mini(variant, GRASS_VARIANTS - 1), 0)]


static func dirt_cell(x: int, y: int) -> Array:
	var h := _hash01(x * 7 + 3, y * 3 + 13)
	if h < 0.93:  # paths mostly plain — sparse stones only
		return [SRC_GREEN_YARD, Vector2i(3, 3)]
	var variant := int((h - 0.93) / 0.07 * DIRT_VARIANTS)
	return [SRC_DIRT_VAR, Vector2i(mini(variant, DIRT_VARIANTS - 1), 0)]
