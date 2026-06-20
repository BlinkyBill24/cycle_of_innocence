extends CanvasLayer
## Dev-only on-screen debug overlay. DEFAULT OFF — it never appears unless the
## developer explicitly presses the toggle (F3). Read-only: shows current zone,
## player coords, the last gameplay trigger, and DreadManager / HollowingClock
## state. No gameplay effect, no autosave, no player-facing objective text — this
## is the ONLY on-screen text the placeholder test build adds, and it is dev-only.
## Not intended to ship; default-off + explicit-toggle is the safeguard.

const TOGGLE_KEY := KEY_F3

var _label: Label
var _last_trigger: String = "—"


func _ready() -> void:
	layer = 128                       # above HUD/touch/dread overlay
	visible = false                   # DEFAULT OFF
	set_process(false)                # only tick while shown
	_label = Label.new()
	_label.position = Vector2(8, 8)
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.6))
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)
	_wire_signals()


func _wire_signals() -> void:
	if GameEvents:
		GameEvents.diggable_revealed.connect(func(id: StringName) -> void: _note("dig %s" % id))
		GameEvents.journal_entry_added.connect(func(id: StringName) -> void: _note("journal %s" % id))
		GameEvents.item_acquired.connect(func(id: StringName, q: int) -> void: _note("item %s x%d" % [id, q]))
		GameEvents.item_used.connect(func(id: StringName) -> void: _note("use %s" % id))
		GameEvents.companion_recalled.connect(func() -> void: _note("recall"))
		GameEvents.horror_stinger.connect(func(t: StringName) -> void: _note("stinger %s" % t))
	if ZoneManager:
		ZoneManager.zone_changed.connect(func(z: StringName) -> void: _note("zone %s" % z))


func _note(s: String) -> void:
	_last_trigger = s


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo \
			and (event as InputEventKey).keycode == TOGGLE_KEY:
		visible = not visible
		set_process(visible)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	_label.text = "%s\n%s\n%s\n%s\n%s\n[F3 hide]" % [
		"ZONE  %s" % (ZoneManager.current_zone_id if ZoneManager else &"?"),
		"POS   %s" % _player_pos_str(),
		"LAST  %s" % _last_trigger,
		"DREAD %s" % _dread_str(),
		"HOLLOW %s" % _hollow_str(),
	]


func _player_pos_str() -> String:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p == null:
		return "—"
	return "%d, %d" % [int(p.global_position.x), int(p.global_position.y)]


func _dread_str() -> String:
	if DreadManager == null:
		return "?"
	var tier := DreadManager.get_tier() if DreadManager.has_method("get_tier") else 0
	return "%.0f (t%d)" % [DreadManager.dread, tier]


func _hollow_str() -> String:
	if HollowingClock == null:
		return "?"
	var name_str := str(HollowingClock.stage_name()) if HollowingClock.has_method("stage_name") else str(HollowingClock.stage)
	return "%s a%.0f" % [name_str, HollowingClock.alarm_points]
