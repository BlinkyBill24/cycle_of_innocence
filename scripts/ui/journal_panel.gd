class_name JournalPanel
extends CanvasLayer
## Minimal viewer for the Journal of observed signs (secrets-and-discovery #5).
## Toggled with J. A memory aid for WITNESSED things — it lists what Rowan has
## seen (lore fragments, doom signs), newest first, and never shows a to-do or
## an undiscovered entry. Folds into the Growth/Memory menu later
## (docs/mechanics/progression.md); standalone panel for now.

const KIND_TINT := {
	0: Color(0.86, 0.84, 0.76),  # LORE — bone white
	1: Color(0.95, 0.78, 0.40),  # DOOM — warning amber
}

var _root: Panel
var _list: VBoxContainer
var _open := false


func _ready() -> void:
	layer = 60  # above HUD/prompts, below dialogue (100)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	if GameEvents:
		GameEvents.journal_entry_added.connect(func(_id: StringName) -> void:
			if _open:
				_refresh())


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_root = Panel.new()
	_root.set_anchors_preset(Control.PRESET_CENTER)
	_root.custom_minimum_size = Vector2(340, 260)
	_root.size = Vector2(340, 260)
	_root.position = -_root.size / 2.0
	add_child(_root)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	_root.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	margin.add_child(col)
	var title := Label.new()
	title.text = "What I Have Seen"
	title.add_theme_font_size_override("font_size", 16)
	col.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 6)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_list)


func toggle() -> void:
	_open = not _open
	visible = _open
	if _open:
		_refresh()


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()
	var entries := Journal.entries_newest_first()
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "Nothing yet. Rowan remembers what she sees."
		empty.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_list.add_child(empty)
		return
	for e: Dictionary in entries:
		var line := Label.new()
		line.text = "• " + str(e["text"])
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.custom_minimum_size = Vector2(300, 0)
		line.add_theme_font_size_override("font_size", 11)
		line.add_theme_color_override("font_color",
			KIND_TINT.get(int(e["kind"]), Color.WHITE))
		_list.add_child(line)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and (event as InputEventKey).keycode == KEY_J:
		toggle()
		get_viewport().set_input_as_handled()
