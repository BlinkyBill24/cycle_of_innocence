extends Node2D
## Temporary vertical-slice debug node — trigger age/morality/companion changes in playground.
## Remove or disable before shipping slice.

@export var show_debug_label: bool = true

var _label: Label


func _ready() -> void:
	if show_debug_label:
		# CanvasLayer so the readout is glued to the screen, not the world —
		# as a world-space child it scrolled away with the camera.
		var overlay := CanvasLayer.new()
		overlay.name = "DebugOverlay"
		overlay.layer = 101  # above the dialogue balloon (100): always visible
		add_child(overlay)
		_label = Label.new()
		_label.add_theme_font_size_override("font_size", 9)
		_label.add_theme_color_override("font_outline_color", Color.BLACK)
		_label.add_theme_constant_override("outline_size", 3)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		overlay.add_child(_label)
		_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		_label.grow_vertical = Control.GROW_DIRECTION_END
		_label.offset_top = 4.0
		_label.offset_right = -6.0
	_refresh_label()
	PlayerData.age_advanced.connect(func(_s): _refresh_label())
	PlayerData.morality_changed.connect(func(_v, _d): _refresh_label())
	PlayerData.bond_changed.connect(func(_id, _v): _refresh_label())
	PlayerData.corruption_changed.connect(func(_id, _v): _refresh_label())
	DreadManager.dread_changed.connect(func(_v, _d): _refresh_label())
	WorldState.time_changed.connect(func(_t2, _d2): _refresh_label())
	HollowingClock.stage_advanced.connect(func(_s): _refresh_label())


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key_event := event as InputEventKey
	match key_event.keycode:
		KEY_1:
			PlayerData.change_morality(-15.0)
		KEY_2:
			PlayerData.change_morality(15.0)
		KEY_3:
			PlayerData.set_age_stage(PlayerData.AgeStage.TEEN)
		KEY_4:
			PlayerData.set_age_stage(PlayerData.AgeStage.ADULT)
		KEY_5:
			PlayerData.set_age_stage(PlayerData.AgeStage.CHILD)
		KEY_6:
			PlayerData.set_companion_bond(PlayerData.BRIAR_ID, PlayerData.get_companion(PlayerData.BRIAR_ID).bond + 10.0)
		KEY_7:
			PlayerData.set_companion_corruption(PlayerData.BRIAR_ID, PlayerData.get_companion(PlayerData.BRIAR_ID).corruption + 15.0)
		KEY_8:
			PlayerData.unlock_revelation(&"escape_noticed")
		KEY_9:
			DreadManager.add_dread(20.0, &"debug")
		KEY_T:
			WorldState.advance_time()
		KEY_H:
			HollowingClock.add_alarm(HollowingClock.ALARM_THRESHOLD)
		KEY_R:
			# replay story dialogues with CURRENT stats (vessel distortion QA)
			# (moved off J 2026-06-13 — J now opens the Journal)
			for node in get_tree().get_nodes_in_group("story_dialogue"):
				(node as StoryDialogue).replay()
		KEY_K:
			SaveManager.save_game()
		KEY_L:
			SaveManager.load_game()
			_refresh_label()
		KEY_0:
			PlayerData.reset_to_defaults()
			DreadManager.reset()
			WorldState.reset()
			HollowingClock.reset()
			Journal.reset()
			get_tree().reload_current_scene()


func _refresh_label() -> void:
	if _label == null:
		return
	var briar: Dictionary = PlayerData.get_companion(PlayerData.BRIAR_ID)
	_label.text = (
		"[Progression Test]\n"
		+ "Age: %s | Morality: %.0f (%s)\n" % [
			PlayerData.AgeStage.keys()[PlayerData.age_stage],
			PlayerData.morality,
			PlayerData.get_morality_tier_name(),
		]
		+ "Briar bond: %.0f | corruption: %.0f\n" % [briar.get("bond", 0.0), briar.get("corruption", 0.0)]
		+ ("Quirks: %s\n" % ", ".join(PlayerData.get_companion_quirks(PlayerData.BRIAR_ID)) if not PlayerData.get_companion_quirks(PlayerData.BRIAR_ID).is_empty() else "")
		+ "Dread: %.0f (%s) | HP: %d/%d | %s day %d\n" % [DreadManager.dread, DreadManager.get_tier_name(), PlayerData.current_hp, PlayerData.max_hp, WorldState.TimeOfDay.keys()[WorldState.time_of_day], WorldState.day]
		+ "Hollowing: %d (%s) | alarm %.0f\n" % [HollowingClock.stage, HollowingClock.stage_name(), HollowingClock.alarm_points]
		+ _enemy_line()
		+ "Keys: 1/2 morality ±15 | 3 teen 4 adult 5 child\n"
		+ "6 bond+10 | 7 corruption+15 | 8 revelation | 9 dread+20 | 0 reset\n"
		+ "K save | L load(after K) | R replay intro | T time | H hollow+1 | E interact | J journal"
	)


func _enemy_line() -> String:
	var enemy := get_tree().get_first_node_in_group("enemy") as EnemyBase
	if enemy == null or not is_instance_valid(enemy):
		return ""
	return "Creature: recognition %.0f%% %s\n" % [
		enemy.recognition, "(STILLED)" if enemy.stilled else ""]


func _process(_delta: float) -> void:
	# live-refresh while soothing so recognition progress is visible
	var enemy := get_tree().get_first_node_in_group("enemy") as EnemyBase
	if enemy and not enemy.stilled and enemy.recognition > 0.0:
		_refresh_label()
