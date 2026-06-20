class_name PlaceholderKit
extends RefCounted
## Single source of truth for the placeholder-mode visual convention — shape +
## colour per node category. PlaceholderMode swaps real art for these flat
## Polygon2D stand-ins so navigation/signposting can be playtested with art
## stripped out. Vector polygons (crisp, Web/Compatibility-renderer safe).
##
## Convention (distinguish node types at a glance):
##   PLAYER       cyan   diamond
##   COMPANION    amber  octagon
##   INTERACTABLE green  square   (DiggableSpot · DoorTransition · hidden book)
##   MONSTER      red    down-triangle
##   PROP         grey   small square
##   BACKDROP     slate  full-rect (flat ground)

enum Cat { PLAYER, COMPANION, INTERACTABLE, MONSTER, PROP, BACKDROP }

const COLORS := {
	Cat.PLAYER: Color(0.20, 0.85, 1.0, 1.0),       # cyan
	Cat.COMPANION: Color(1.0, 0.80, 0.20, 1.0),    # amber
	Cat.INTERACTABLE: Color(0.30, 1.0, 0.42, 1.0), # green
	Cat.MONSTER: Color(1.0, 0.22, 0.26, 1.0),      # red
	Cat.PROP: Color(0.52, 0.52, 0.58, 0.9),        # grey
	Cat.BACKDROP: Color(0.14, 0.15, 0.18, 1.0),    # dark slate
}

## Default footprint per category (px); PlaceholderMode may override.
const SIZES := {
	Cat.PLAYER: 26.0,
	Cat.COMPANION: 22.0,
	Cat.INTERACTABLE: 18.0,
	Cat.MONSTER: 28.0,
	Cat.PROP: 18.0,
}

## Group every stand-in joins, so PlaceholderMode can find/remove them and the
## tree walk can skip them (never skin a placeholder).
const GROUP := &"_placeholder"


## Build the flat stand-in for a category. Always grouped GROUP.
static func make(cat: int, size: float = -1.0) -> Polygon2D:
	var s: float = size if size > 0.0 else float(SIZES.get(cat, 20.0))
	var p := Polygon2D.new()
	p.color = COLORS[cat]
	p.polygon = _shape(cat, s)
	p.add_to_group(GROUP)
	return p


## Flat backdrop rectangle covering a Sprite2D's world-space texture rect.
static func make_backdrop(rect_size: Vector2) -> Polygon2D:
	var p := Polygon2D.new()
	p.color = COLORS[Cat.BACKDROP]
	var w := absf(rect_size.x) / 2.0
	var h := absf(rect_size.y) / 2.0
	p.polygon = PackedVector2Array([Vector2(-w, -h), Vector2(w, -h), Vector2(w, h), Vector2(-w, h)])
	p.add_to_group(GROUP)
	return p


static func _shape(cat: int, s: float) -> PackedVector2Array:
	var h := s / 2.0
	match cat:
		Cat.PLAYER:  # diamond
			return PackedVector2Array([Vector2(0, -h), Vector2(h, 0), Vector2(0, h), Vector2(-h, 0)])
		Cat.COMPANION:  # octagon
			var pts := PackedVector2Array()
			for i in 8:
				var a := PI / 8.0 + i * (TAU / 8.0)
				pts.append(Vector2(cos(a), sin(a)) * h)
			return pts
		Cat.MONSTER:  # down-pointing triangle
			return PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(0, h)])
		_:  # INTERACTABLE / PROP / fallback — square
			return PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
