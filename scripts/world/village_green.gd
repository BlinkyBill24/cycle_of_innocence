class_name VillageGreenZone
extends ZoneRoot
## The village at golden hour (village-life.md): a green ringed by a cobble
## path, lanes out to the gates, swept yards by the houses. Rowan watches
## normal life continue from hiding — being SEEN is the threat here.
## Wang painting identical in approach to playground_fringes.gd.

## Paths are packed DIRT, not cobble (user tileset reference 2026-06-11:
## farming-village look, and the cobble set rendered as a raised curb).
## One upper terrain = no forbidden pairs anywhere.
enum Terrain { GREEN, DIRT }

const SRC_GREEN_COBBLE := 0  # lawn -> cobblestone (unused; kept for interiors)
const SRC_GREEN_YARD := 1    # village_yard tileset: lawn -> packed dirt

const WIDTH := 44
const HEIGHT := 28

const RING_RADIUS := 7.5
const RING_HALF_WIDTH := 1.0
const LANE_HALF_WIDTH := 1
const YARDS: Array[Rect2i] = [
	Rect2i(-16, -11, 6, 4),  # NW — Marta's house
	Rect2i(10, -11, 6, 4),   # NE
	Rect2i(-15, 8, 6, 4),    # SW
	Rect2i(9, 8, 6, 4),      # SE — Pieter's house
]
const CHAPEL_COURT := Rect2i(-2, -13, 5, 4)  # forecourt, joined by the north lane

@onready var ground: TileMapLayer = $Ground
@onready var tint: CanvasModulate = $DuskTint


func _ready() -> void:
	super._ready()
	_paint_ground()
	tint.color = WorldState.palette()
	WorldState.time_changed.connect(func(_t: int, _d: int) -> void:
		create_tween().tween_property(tint, "color", WorldState.palette(), 3.0))


func _paint_ground() -> void:
	for y in range(-HEIGHT / 2, HEIGHT / 2):
		for x in range(-WIDTH / 2, WIDTH / 2):
			var pick: Array = cell_tile(x, y)
			ground.set_cell(Vector2i(x, y), pick[0], pick[1])


static func vertex_terrain(vx: int, vy: int) -> Terrain:
	# dirt: ring around the green + west-east lane + north lane + forecourt + yards
	var dist := sqrt(float(vx * vx + vy * vy))
	if absf(dist - RING_RADIUS) <= RING_HALF_WIDTH:
		return Terrain.DIRT
	if absi(vy) <= LANE_HALF_WIDTH:
		return Terrain.DIRT
	if absi(vx) <= LANE_HALF_WIDTH and vy < 0 and vy >= -10:
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


static func cell_tile(x: int, y: int) -> Array:
	return wang_tile(vertex_terrain(x, y), vertex_terrain(x + 1, y),
			vertex_terrain(x, y + 1), vertex_terrain(x + 1, y + 1))


static func wang_tile(nw: Terrain, ne: Terrain, sw: Terrain, se: Terrain) -> Array:
	var corners: Array[Terrain] = [nw, ne, sw, se]
	var idx := 0
	for i in corners.size():
		idx = idx << 1 | (1 if corners[i] == Terrain.DIRT else 0)
	return [SRC_GREEN_YARD, Vector2i(idx % 4, idx / 4)]
