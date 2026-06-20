class_name JournalPanel
extends CanvasLayer
## Growth / Memory menu (docs/mechanics/progression.md), toggled with J. A
## stats header (age, morality tier, Briar's bond) over the Journal of observed
## signs — a memory aid for WITNESSED things only (secrets-and-discovery #5):
## lore fragments + doom signs, newest first, never a to-do or undiscovered
## entry. The Journal half holds the line; the header is the "Growth" screen
## the progression doc always called for.

const KIND_TINT := {
	0: Color(0.86, 0.84, 0.76),  # LORE — bone white
	1: Color(0.95, 0.78, 0.40),  # DOOM — warning amber
}

var _root: Panel
var _list: VBoxContainer
var _stats: Label
var _open := false
var _self_pause := false  # true while WE emit exploration_paused (ignore our own)


func _ready() -> void:
	layer = 60  # above HUD/prompts, below dialogue (100)
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	if GameEvents:
		GameEvents.journal_entry_added.connect(func(_id: StringName) -> void:
			if _open:
				_refresh())
		# Dialogue/the satchel pausing exploration -> the journal yields (mirrors
		# inventory_panel) so two modals never stack and the world freeze pairs cleanly.
		GameEvents.exploration_paused.connect(_on_exploration_paused)


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_root = Panel.new()
	_root.set_anchors_preset(Control.PRESET_CENTER)
	_root.custom_minimum_size = Vector2(340, 300)
	_root.size = Vector2(340, 300)
	_root.position = -_root.size / 2.0
	add_child(_root)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	_root.add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	margin.add_child(col)
	# Growth header (age / morality / bond) — the "Memory" screen stats
	_stats = Label.new()
	_stats.add_theme_font_size_override("font_size", 11)
	_stats.add_theme_color_override("font_color", Color(0.72, 0.78, 0.72))
	col.add_child(_stats)
	var sep := HSeparator.new()
	col.add_child(sep)
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
	if _open:
		_close()
	else:
		_open_panel()


## Opening the journal freezes the world like the satchel — you shouldn't be
## chased or hit while reading (playtest 2026-06-20). Strict pause/resume pairing.
func _open_panel() -> void:
	_open = true
	if GameEvents:
		_self_pause = true
		GameEvents.exploration_paused.emit()
		_self_pause = false
	visible = true
	_refresh()


func _close() -> void:
	_open = false
	visible = false
	if GameEvents:
		GameEvents.exploration_resumed.emit()


## A foreign pause (dialogue / the satchel) opened: yield WITHOUT emitting resume
## (the pauser owns the resume), guarded against our own emission.
func _on_exploration_paused() -> void:
	if _self_pause:
		return
	if _open:
		_open = false
		visible = false


func _refresh() -> void:
	_refresh_stats()
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


func _refresh_stats() -> void:
	var age := String(PlayerData.AgeStage.keys()[PlayerData.age_stage]).capitalize()
	var tier := String(PlayerData.get_morality_tier_name()).capitalize()
	var briar: Dictionary = PlayerData.get_companion(PlayerData.BRIAR_ID)
	var bond := int(briar.get("bond", 0.0))
	_stats.text = "%s  ·  %s (%d)  ·  Briar bond %d" % [
		PlayerData.custom_name, tier, int(PlayerData.morality), bond]


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and (event as InputEventKey).keycode == KEY_J:
		toggle()
		get_viewport().set_input_as_handled()
