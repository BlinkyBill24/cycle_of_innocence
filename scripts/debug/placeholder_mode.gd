extends Node
## Reversible "placeholder mode" (throwaway navigation/signposting playtest):
## strips visible art down to flat PlaceholderKit stand-ins so layout — not art —
## carries wayfinding. ADDITIVE + FULLY REVERSIBLE: originals are only *hidden*
## (visible=false) and a placeholder child/sibling is added; nothing on disk is
## touched, no node is deleted, no quest logic runs here. Audio, physics, y-sort,
## collision and every behaviour are untouched — visuals only. Flip `enabled`
## (or `set_enabled`) to swap back losslessly.
##
## Classification is by the project's existing groups (player/companion/enemy,
## diggable/interior_door/searchable), so it tracks the quest without per-scene
## wiring. Re-skins on every ZoneManager.zone_changed (covers boot + transitions).

const SETTING := "debug/placeholder_mode"  # ProjectSettings override (optional)
const DEFAULT_ENABLED := false             # default OFF: show the real art. Set the
                                           # `debug/placeholder_mode` project setting
                                           # true to re-run the navigation playtest.

var enabled: bool = DEFAULT_ENABLED

var _placeholders: Array[Node] = []     # stand-ins WE added (freed on restore)
var _hidden: Array[CanvasItem] = []     # originals WE hid (re-shown on restore)
var _handled: Dictionary = {}           # instance_id set — skip already-skinned subtrees


func _ready() -> void:
	enabled = bool(ProjectSettings.get_setting(SETTING, DEFAULT_ENABLED))
	if ZoneManager and not ZoneManager.zone_changed.is_connected(_on_zone_changed):
		ZoneManager.zone_changed.connect(_on_zone_changed)
	_reskin.call_deferred()  # boot scene may already be up


func _on_zone_changed(_zone_id: StringName) -> void:
	_reskin.call_deferred()


## Public toggle (debug overlay / console / project setting flip). Reversible.
func set_enabled(on: bool) -> void:
	if on == enabled:
		return
	enabled = on
	_reskin()


func is_enabled() -> bool:
	return enabled


# --- skin / restore ---

func _reskin() -> void:
	_restore()
	if enabled:
		var scene := get_tree().current_scene
		if scene:
			skin_tree(scene)


## Restore everything to the real art (idempotent). Public for tests.
func _restore() -> void:
	for ph in _placeholders:
		if is_instance_valid(ph):
			ph.queue_free()
	_placeholders.clear()
	for ci in _hidden:
		if is_instance_valid(ci):
			ci.visible = true
	_hidden.clear()
	_handled.clear()


## Walk `root` and skin every classifiable node. Public for tests (pass a
## hand-built subtree instead of the live current_scene).
func skin_tree(root: Node) -> void:
	_handled.clear()
	var nodes: Array[Node] = []
	_collect(root, nodes)
	for n in nodes:
		_skin_node(n)


func _collect(n: Node, out: Array[Node]) -> void:
	for c in n.get_children():
		if c is CanvasLayer:
			continue  # never recurse into UI layers (HUD, touch, overlays)
		if c.is_in_group(PlaceholderKit.GROUP):
			continue
		out.append(c)
		_collect(c, out)


func _skin_node(n: Node) -> void:
	if _handled.has(n.get_instance_id()):
		return
	if n.is_in_group("player"):
		_swap_body(n, PlaceholderKit.Cat.PLAYER)
	elif n.is_in_group("companion"):
		_swap_body(n, PlaceholderKit.Cat.COMPANION)
	elif n.is_in_group("enemy"):
		_swap_body(n, PlaceholderKit.Cat.MONSTER)
	elif n.is_in_group("diggable") or n.is_in_group("interior_door") or n.is_in_group("searchable"):
		_swap_interactable(n)
	elif n is Sprite2D:
		if n.name == "GroundBackdrop":
			_swap_backdrop(n)
		else:
			_swap_prop(n)
	elif n.is_class("TileMap") or n.is_class("TileMapLayer"):
		_hide(n as CanvasItem)  # strip decorative tiles (none in zones today; future-safe)


# --- per-category swaps ---

func _swap_body(body: Node, cat: int) -> void:
	var spr := body.get_node_or_null("AnimatedSprite2D") as CanvasItem
	_hide(spr)
	var ph := PlaceholderKit.make(cat)
	ph.z_index = 1
	body.add_child(ph)  # child of the body → moves with it, keeps y-sort
	_placeholders.append(ph)
	_mark_subtree(body)


func _swap_interactable(area: Node) -> void:
	for c in area.get_children():  # hide its own markers/glints/sprites
		if c is CanvasItem and not c.is_in_group(PlaceholderKit.GROUP):
			_hide(c)
	var ph := PlaceholderKit.make(PlaceholderKit.Cat.INTERACTABLE)
	ph.z_index = 1
	area.add_child(ph)
	_placeholders.append(ph)
	_mark_subtree(area)


func _swap_backdrop(spr: Sprite2D) -> void:
	var size := Vector2(spr.texture.get_size()) * spr.scale if spr.texture else Vector2(4096, 4096)
	var ph := PlaceholderKit.make_backdrop(size)
	ph.z_index = -100  # behind everything (it is the ground)
	ph.position = spr.position
	spr.get_parent().add_child(ph)
	_hide(spr)
	_placeholders.append(ph)
	_mark_subtree(spr)


func _swap_prop(spr: Sprite2D) -> void:
	var ph := PlaceholderKit.make(PlaceholderKit.Cat.PROP)
	ph.position = spr.position  # same parent → same y-sort bucket
	spr.get_parent().add_child(ph)
	_hide(spr)
	_placeholders.append(ph)
	_mark_subtree(spr)


# --- helpers ---

func _hide(ci: CanvasItem) -> void:
	if ci and ci.visible:
		ci.visible = false
		_hidden.append(ci)


func _mark_subtree(n: Node) -> void:
	_handled[n.get_instance_id()] = true
	for c in n.get_children():
		_mark_subtree(c)
