extends CanvasLayer
## InventoryPanel (autoload singleton — no `class_name`, since the autoload name
## "InventoryPanel" already provides the global accessor and a matching class_name
## would collide with it, mirroring how journal_panel.gd is scene-instanced while
## the Journal singleton is a separate autoload).
##
## The Satchel — a code-built modal viewer for the 10-slot inventory (vertical
## slice). Toggled with I (action `inventory_toggle`) or a touch button. Clones
## the journal_panel.gd / soothe_prompt.gd code-built CanvasLayer + paused/resumed
## modal pattern.
##
## INTERFACE-HORROR HARD CONTRACT (docs/mechanics/interface-horror.md): this menu
## NEVER degrades. It is built on plain Control nodes — NOT the player input-buffer
## path — so the control-degradation layer physically cannot reach it. The ONLY
## thing morality changes is item DESCRIPTION TEXT (Inventory.describe ->
## ItemDef.read_description swaps to distorted_description at HARDENED/VESSEL).
## Layout, icons, controls, slot count, and readability are constant at every tier.
##
## Dialogue/cutscene always wins: the panel force-closes on exploration_paused so
## it can never stack over a dialogue beat, and it pairs its own
## exploration_paused/resumed strictly (the pauser owns the resume).

const SLOT_COUNT := 10
const COLUMNS := 5
const SLOT_SIZE := Vector2(56, 56)
const DISTORTED_TEXT_COLOR := Color("#b39ddb")  # established morality cue
const EQUIPPED_TINT := Color(1.0, 0.92, 0.55)  # the wielded weapon's slot glows warm

var _root: Panel
var _grid: GridContainer
var _detail_name: Label
var _detail_desc: Label
var _slots: Array[Button] = []
## "Kept" = permanent KEY items (the flute, a key) shown in their own section, so a
## permanent unlock reads as a thing you HAVE, not lost among the consumable pockets.
var _kept_label: Label
var _kept_box: HBoxContainer
var _open := false
var _self_pause := false  # true while WE emit exploration_paused, so our own handler ignores it
var _selected_index := -1

## Eat-vs-feed choice overlay (decision 2026-06-21): a sub-modal shown ONLY for
## dual-use food (heals Rowan AND feeds a companion) so the player owns the
## "share or keep" choice at the point of use. Plain Control nodes — same
## interface-horror hard contract as the bag: it never degrades.
var _choice_open := false
var _choice_id: StringName = &""
var _choice_blocker: ColorRect
var _choice_panel: Panel
var _choice_title: Label
var _choice_eat_btn: Button
var _choice_feed_btn: Button


func _ready() -> void:
	layer = 60  # above HUD/prompts (15/20), below dialogue (100)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # repaint while exploration is paused
	_build()
	if GameEvents:
		GameEvents.inventory_changed.connect(func() -> void:
			if _open:
				_refresh())
		# Dialogue/cutscene pauses exploration -> the satchel must yield, without
		# emitting a resume (whoever paused owns it). Prevents a double-pause wedge.
		GameEvents.exploration_paused.connect(_on_exploration_paused)


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	_root = Panel.new()
	_root.set_anchors_preset(Control.PRESET_CENTER)
	_root.custom_minimum_size = Vector2(420, 320)
	_root.size = Vector2(420, 320)
	_root.position = -_root.size / 2.0
	add_child(_root)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	_root.add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	margin.add_child(col)

	var title := Label.new()
	title.text = "Satchel"
	title.add_theme_font_size_override("font_size", 16)
	col.add_child(title)

	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 6)
	_grid.add_theme_constant_override("v_separation", 6)
	col.add_child(_grid)

	# Exactly SLOT_COUNT slots are ALWAYS drawn (dim placeholder when empty) so
	# the 10-slot scarcity is visible — a Zelda/Mana satchel, not a bottomless bag.
	for i in SLOT_COUNT:
		var slot := _make_slot(i)
		_grid.add_child(slot)
		_slots.append(slot)

	# Kept (permanent items) — their own category so the flute/key read as held, not
	# lost among the consumable pockets (playtest 2026-06-21).
	_kept_label = Label.new()
	_kept_label.text = "Kept"
	_kept_label.add_theme_font_size_override("font_size", 12)
	_kept_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.95))  # cool = permanent
	col.add_child(_kept_label)
	_kept_box = HBoxContainer.new()
	_kept_box.add_theme_constant_override("separation", 10)
	col.add_child(_kept_box)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(spacer)

	_detail_name = Label.new()
	_detail_name.add_theme_font_size_override("font_size", 13)
	col.add_child(_detail_name)

	_detail_desc = Label.new()
	_detail_desc.add_theme_font_size_override("font_size", 11)
	_detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_desc.custom_minimum_size = Vector2(392, 44)
	col.add_child(_detail_desc)

	_build_choice()


## The eat-vs-feed choice sub-modal. Built once, hidden; shown over the bag for
## dual-use food. Added to the CanvasLayer AFTER _root so it draws on top; a
## full-rect blocker eats any click meant for the bag behind it. Web-safe: WORD
## labels only — heart glyphs (♥) don't exist in the web export's fallback font.
func _build_choice() -> void:
	_choice_blocker = ColorRect.new()
	_choice_blocker.color = Color(0, 0, 0, 0.55)
	_choice_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	_choice_blocker.mouse_filter = Control.MOUSE_FILTER_STOP  # swallow clicks to the bag
	_choice_blocker.visible = false
	add_child(_choice_blocker)

	_choice_panel = Panel.new()
	_choice_panel.set_anchors_preset(Control.PRESET_CENTER)
	_choice_panel.custom_minimum_size = Vector2(340, 160)
	_choice_panel.size = Vector2(340, 160)
	_choice_panel.position = -_choice_panel.size / 2.0
	_choice_panel.visible = false
	add_child(_choice_panel)

	var cmargin := MarginContainer.new()
	cmargin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		cmargin.add_theme_constant_override("margin_" + side, 16)
	_choice_panel.add_child(cmargin)

	var ccol := VBoxContainer.new()
	ccol.add_theme_constant_override("separation", 10)
	ccol.alignment = BoxContainer.ALIGNMENT_CENTER
	cmargin.add_child(ccol)

	_choice_title = Label.new()
	_choice_title.add_theme_font_size_override("font_size", 14)
	_choice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ccol.add_child(_choice_title)

	var prompt := Label.new()
	prompt.text = "Eat it yourself, or give it away?"
	prompt.add_theme_font_size_override("font_size", 11)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ccol.add_child(prompt)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	ccol.add_child(row)

	_choice_eat_btn = Button.new()
	_choice_eat_btn.custom_minimum_size = Vector2(150, 50)
	_choice_eat_btn.focus_mode = Control.FOCUS_ALL
	_choice_eat_btn.pressed.connect(_choose_eat)
	row.add_child(_choice_eat_btn)

	_choice_feed_btn = Button.new()
	_choice_feed_btn.custom_minimum_size = Vector2(150, 50)
	_choice_feed_btn.focus_mode = Control.FOCUS_ALL
	_choice_feed_btn.pressed.connect(_choose_feed)
	row.add_child(_choice_feed_btn)

	var hint := Label.new()
	hint.text = "Left / Right to pick.  Esc to cancel."  # ASCII only (web fallback font)
	hint.add_theme_font_size_override("font_size", 9)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate = Color(1, 1, 1, 0.6)
	ccol.add_child(hint)


## One slot = a Button (focus/click/hover) holding an icon TextureRect + a
## bottom-right quantity Label. Built once; _refresh repaints contents only.
func _make_slot(index: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = SLOT_SIZE
	btn.focus_mode = Control.FOCUS_ALL
	btn.clip_contents = true

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  # crisp pixel art
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(icon)

	# Placeholder fill for an item with no icon asset yet (never blanks a slot).
	var placeholder := ColorRect.new()
	placeholder.name = "Placeholder"
	placeholder.color = Color(0.5, 0.45, 0.4, 0.5)
	placeholder.set_anchors_preset(Control.PRESET_FULL_RECT)
	placeholder.offset_left = 12
	placeholder.offset_top = 12
	placeholder.offset_right = -12
	placeholder.offset_bottom = -12
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder.visible = false
	btn.add_child(placeholder)

	var qty := Label.new()
	qty.name = "Qty"
	qty.add_theme_font_size_override("font_size", 11)
	qty.add_theme_color_override("font_outline_color", Color.BLACK)
	qty.add_theme_constant_override("outline_size", 3)
	qty.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	qty.offset_left = -22
	qty.offset_top = -18
	qty.offset_right = -3
	qty.offset_bottom = -2
	qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	qty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(qty)

	btn.pressed.connect(_on_slot_activated.bind(index))
	btn.mouse_entered.connect(func() -> void: _select(index))
	btn.focus_entered.connect(func() -> void: _select(index))
	return btn


## --- modal open/close (strict exploration_paused/resumed pairing) ---

func toggle() -> void:
	if _open:
		_close()
	else:
		_open_panel()


func _open_panel() -> void:
	_open = true
	# Pause BEFORE showing so the world freezes the same frame the satchel appears.
	# Flag the emission as our own so _on_exploration_paused doesn't force-close us.
	if GameEvents:
		_self_pause = true
		GameEvents.exploration_paused.emit()
		_self_pause = false
	visible = true
	_refresh()
	# Focus the first occupied slot for keyboard/gamepad; harmless on touch.
	if not _slots.is_empty():
		var first: int = _first_occupied_index()
		_slots[maxi(first, 0)].grab_focus()


func _close() -> void:
	_open = false
	_hide_choice()  # never leave the choice overlay lingering after the bag closes
	visible = false
	# Resume AFTER hiding (strict pairing — pause-listeners verify the freeze).
	if GameEvents:
		GameEvents.exploration_resumed.emit()


## Dialogue/cutscene paused exploration: yield WITHOUT emitting resume (the
## pauser owns the resume). Guarded against our own pause emission.
func _on_exploration_paused() -> void:
	if _self_pause:
		return  # our own pause emission — not a foreign pause to yield to
	if _open:
		_open = false
		_hide_choice()  # dialogue/cutscene wins — drop the choice overlay too
		visible = false


## --- contents ---

func _refresh() -> void:
	var slots: Array[Dictionary] = Inventory.slots()
	for i in SLOT_COUNT:
		var btn: Button = _slots[i]
		var icon: TextureRect = btn.get_node("Icon") as TextureRect
		var placeholder: ColorRect = btn.get_node("Placeholder") as ColorRect
		var qty: Label = btn.get_node("Qty") as Label
		if i < slots.size():
			var id: StringName = StringName(str(slots[i].get("id", "")))
			var quantity: int = int(slots[i].get("quantity", 0))
			var def: ItemDef = ItemRegistry.get_def(id)
			btn.disabled = false
			btn.tooltip_text = def.display_name if def != null else String(id)
			if def != null and def.icon != null:
				icon.texture = def.icon
				placeholder.visible = false
			else:
				icon.texture = null
				placeholder.visible = true
			qty.text = ("x%d" % quantity) if quantity > 1 else ""
			# the wielded weapon's slot glows so equipping is visible at a glance
			btn.modulate = EQUIPPED_TINT if id == PlayerData.equipped_weapon else Color.WHITE
		else:
			# Empty slot: dim, non-interactive, but always drawn.
			btn.disabled = true
			btn.tooltip_text = ""
			icon.texture = null
			placeholder.visible = false
			qty.text = ""
			btn.modulate = Color.WHITE
	_refresh_kept(slots)
	# Keep the detail panel coherent with what is now present.
	if _selected_index >= slots.size():
		_selected_index = -1
	_update_detail()


## True for a permanent "kept" item — a KEY item (the flute, a key) you hold onto.
## Pure/testable; the satchel's separate category keys off this.
static func is_kept(def: ItemDef) -> bool:
	return def != null and def.category == ItemDef.Category.KEY


## Repaint the Kept strip from the held KEY items (read-only — they have no slot
## action; they're inspected, equipped weapons live in the bag grid).
func _refresh_kept(slots: Array[Dictionary]) -> void:
	if _kept_box == null:
		return
	for child in _kept_box.get_children():
		child.queue_free()
	var any := false
	for row: Dictionary in slots:
		var def: ItemDef = ItemRegistry.get_def(StringName(str(row.get("id", ""))))
		if is_kept(def):
			any = true
			_kept_box.add_child(_make_kept_chip(def))
	_kept_label.visible = any
	_kept_box.visible = any


func _make_kept_chip(def: ItemDef) -> Control:
	var chip := VBoxContainer.new()
	chip.alignment = BoxContainer.ALIGNMENT_CENTER
	chip.tooltip_text = def.display_name
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(28, 28)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if def.icon != null:
		icon.texture = def.icon
	else:
		var ph := ColorRect.new()  # no icon yet -> a small warm chip so it still reads
		ph.color = Color(0.62, 0.58, 0.5, 0.8)
		ph.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.add_child(ph)
	chip.add_child(icon)
	var name_label := Label.new()
	name_label.text = def.display_name
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.add_child(name_label)
	return chip


func _select(index: int) -> void:
	_selected_index = index
	_update_detail()


func _update_detail() -> void:
	var slots: Array[Dictionary] = Inventory.slots()
	if _selected_index < 0 or _selected_index >= slots.size():
		_detail_name.text = ""
		_detail_desc.text = "Ten pockets. Choose what is worth carrying."
		_detail_desc.remove_theme_color_override("font_color")
		return
	var id: StringName = StringName(str(slots[_selected_index].get("id", "")))
	var def: ItemDef = ItemRegistry.get_def(id)
	_detail_name.text = def.display_name if def != null else String(id)
	var body := Inventory.describe(id)
	# Tell the player a weapon is tap-to-equip (and which one is wielded) — the
	# equip verb was invisible before (playtest).
	var affordance := weapon_affordance(def, def != null and PlayerData.equipped_weapon == id)
	if not affordance.is_empty():
		body += "\n" + affordance
	var food := food_affordance(def)
	if not food.is_empty():
		body += "\n" + food
	_detail_desc.text = body
	# Morality TEXTURE only: tint the distorted variant with the established cue.
	# Effects/layout/readability are identical at every tier.
	if def != null and _is_distorted(def):
		_detail_desc.add_theme_color_override("font_color", DISTORTED_TEXT_COLOR)
	else:
		_detail_desc.remove_theme_color_override("font_color")


## True for a food that can BOTH heal Rowan and feed a companion — the only items
## that pop the eat-vs-feed choice. The deliberate "share or keep" tension lives
## exactly here (berries, dried meat). Pure/testable.
static func is_dual_use(def: ItemDef) -> bool:
	return def != null \
		and def.heal_hearts > 0 \
		and def.use_kind == ItemDef.UseKind.FEED_COMPANION \
		and not def.companion_id.is_empty()


## One-line affordance telling the player what tapping a food does, so the verb is
## never invisible (the panel's guiding principle). Empty for non-food. Pure/testable.
static func food_affordance(def: ItemDef) -> String:
	if def == null:
		return ""
	if is_dual_use(def):
		return "Tap: eat to heal, or give to %s" % String(def.companion_id).capitalize()
	if def.heal_hearts > 0:
		return "Tap to eat"
	if def.use_kind == ItemDef.UseKind.FEED_COMPANION and not def.companion_id.is_empty():
		return "Tap to give to %s" % String(def.companion_id).capitalize()
	return ""


## Weapon affordance line for the detail panel — empty for non-weapons.
## Pure/testable.
static func weapon_affordance(def: ItemDef, is_equipped: bool) -> String:
	if def == null:
		return ""
	if def.use_kind != ItemDef.UseKind.EQUIP and def.use_kind != ItemDef.UseKind.THROW:
		return ""
	return "Equipped — tap to put it away" if is_equipped else "Tap to equip"


## True when read_description() is currently returning the distorted variant.
func _is_distorted(def: ItemDef) -> bool:
	if def.distorted_description.is_empty():
		return false
	if not PlayerData:
		return false
	return PlayerData.get_morality_tier() >= PlayerData.MoralityTier.HARDENED


func _on_slot_activated(index: int) -> void:
	if _choice_open:
		return  # captive: a bag tap can't act on the world while the choice is up
	_select(index)
	var slots: Array[Dictionary] = Inventory.slots()
	if index < 0 or index >= slots.size():
		return
	var id: StringName = StringName(str(slots[index].get("id", "")))
	var def: ItemDef = ItemRegistry.get_def(id)
	if def == null:
		return
	# Eat-vs-feed at the point of use (decision 2026-06-21, "ask at point of use"):
	#  - DUAL-USE food (heals Rowan AND feeds a companion) -> pop the choice prompt so
	#    the player owns the "share or keep" tension the bible centres on.
	#  - pure food -> eaten; companion-only care -> given; key/lore -> inspect-only.
	if is_dual_use(def):
		_open_choice(id, def)
	elif def.heal_hearts > 0:
		Inventory.eat(id)
	elif def.category == ItemDef.Category.COMPANION_CARE \
			or def.category == ItemDef.Category.CONSUMABLE:
		Inventory.use(id)  # inventory_changed -> _refresh repaints; detail stays coherent


## --- eat-vs-feed choice sub-modal ---

## Show the choice for a dual-use food. Labels are computed from the item so a new
## dual-use food needs no UI change. WORD labels only (web-font safe).
func _open_choice(id: StringName, def: ItemDef) -> void:
	_choice_id = id
	_choice_open = true
	_choice_title.text = def.display_name
	var hearts := def.heal_hearts
	# At full health eating is a no-op (no heal, no waste) — so disable Eat (not a dead
	# default) and hand focus to Give. Word labels only (web fallback font has no ♥).
	var full: bool = PlayerData.current_hp >= PlayerData.max_hp
	_choice_eat_btn.disabled = full
	_choice_eat_btn.text = "Eat  (already full)" if full \
		else "Eat  (+%d %s)" % [hearts, "heart" if hearts == 1 else "hearts"]
	var who := String(def.companion_id).capitalize()
	_choice_feed_btn.text = "Give to %s  (+%d bond)" % [who, int(def.bond_delta)]
	_set_slots_focusable(false)  # captive modal — keyboard/gamepad focus can't escape
	_choice_blocker.visible = true
	_choice_panel.visible = true
	# Default focus: Eat normally; Give when Eat is disabled (Rowan already full).
	if full:
		_choice_feed_btn.grab_focus()
	else:
		_choice_eat_btn.grab_focus()


func _choose_eat() -> void:
	_resolve_choice(true)


func _choose_feed() -> void:
	_resolve_choice(false)


## Apply the picked verb, then dismiss and hand focus back to the bag.
func _resolve_choice(eat: bool) -> void:
	var id := _choice_id
	_hide_choice()
	if not id.is_empty():
		if eat:
			Inventory.eat(id)
		else:
			Inventory.use(id)  # use_kind FEED_COMPANION -> feeds the companion (bond)
	_restore_bag_focus()


## Cancel the choice (Esc / toggle): back to the bag, nothing consumed.
func _close_choice() -> void:
	if not _choice_open:
		return
	_hide_choice()
	_restore_bag_focus()


## Hide the overlay without touching focus — used by _resolve_choice/_close_choice
## and when the whole panel yields or closes (so it can't linger over the world).
func _hide_choice() -> void:
	_choice_open = false
	_choice_id = &""
	_set_slots_focusable(true)  # bag slots take focus again
	if _choice_blocker != null:
		_choice_blocker.visible = false
	if _choice_panel != null:
		_choice_panel.visible = false


## Toggle whether the bag slots can take keyboard/gamepad focus — off while the
## choice sub-modal is captive so arrow keys can't reach a slot behind the overlay.
func _set_slots_focusable(on: bool) -> void:
	var mode := Control.FOCUS_ALL if on else Control.FOCUS_NONE
	for s in _slots:
		s.focus_mode = mode


func _restore_bag_focus() -> void:
	if not _open or _slots.is_empty():
		return
	var slots: Array[Dictionary] = Inventory.slots()
	var idx := _selected_index
	if idx < 0 or idx >= slots.size():
		idx = _first_occupied_index()
	_slots[maxi(idx, 0)].grab_focus()


## --- input ---

func _unhandled_input(event: InputEvent) -> void:
	# The choice sub-modal is captive: while it's up, only its own keys matter.
	# Eat/Give are focusable Buttons (Enter/Space confirm, Left/Right swap focus,
	# tap/click work) — here we only add Esc/I to cancel back to the bag.
	if _choice_open:
		if event is InputEventKey:
			var ck := event as InputEventKey
			if ck.pressed and not ck.echo and (ck.keycode == KEY_ESCAPE or ck.keycode == KEY_I):
				_close_choice()
				get_viewport().set_input_as_handled()
		return
	# Action-based (project.godot maps `inventory_toggle` -> I) with a raw KEY_I
	# fallback so the panel works even before the action is wired (parity with
	# journal_panel's KEY_J model).
	var toggled := false
	if InputMap.has_action(&"inventory_toggle") and event.is_action_pressed(&"inventory_toggle"):
		toggled = true
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo and key.keycode == KEY_I:
			toggled = true
	if toggled:
		toggle()
		get_viewport().set_input_as_handled()
		return
	# While open, swallow Escape to close (a friendly modal exit).
	if _open and event is InputEventKey:
		var k := event as InputEventKey
		if k.pressed and not k.echo and k.keycode == KEY_ESCAPE:
			_close()
			get_viewport().set_input_as_handled()


## --- helpers ---

func _first_occupied_index() -> int:
	var slots: Array[Dictionary] = Inventory.slots()
	for i in slots.size():
		var row: Dictionary = slots[i]
		if not StringName(row.get("id", &"")).is_empty():
			return i
	return 0


## Touch parity: external open button (touch_controls.gd) calls this. Mirrors the
## I key. SlotButtons are real Control nodes already accepting touch/gui_input,
## so feeding/inspecting works on touch once the panel is open.
func open_via_touch() -> void:
	if not _open:
		_open_panel()


func is_open() -> bool:
	return _open
