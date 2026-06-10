extends Node2D
## Temporary vertical-slice debug node — trigger age/morality/companion changes in playground.
## Remove or disable before shipping slice.

@export var show_debug_label: bool = true

var _label: Label


func _ready() -> void:
	if show_debug_label:
		_label = Label.new()
		_label.position = Vector2(8, 8)
		_label.add_theme_font_size_override("font_size", 11)
		add_child(_label)
	_refresh_label()
	PlayerData.age_advanced.connect(func(_s): _refresh_label())
	PlayerData.morality_changed.connect(func(_v, _d): _refresh_label())
	PlayerData.bond_changed.connect(func(_id, _v): _refresh_label())
	PlayerData.corruption_changed.connect(func(_id, _v): _refresh_label())
	DreadManager.dread_changed.connect(func(_v, _d): _refresh_label())


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
		KEY_K:
			SaveManager.save_game()
		KEY_L:
			SaveManager.load_game()
			_refresh_label()
		KEY_0:
			PlayerData.reset_to_defaults()
			DreadManager.reset()
			_refresh_label()


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
		+ "Dread: %.0f (%s) | HP: %d/%d\n" % [DreadManager.dread, DreadManager.get_tier_name(), PlayerData.current_hp, PlayerData.max_hp]
		+ "Keys: 1/2 morality ±15 | 3 teen 4 adult 5 child\n"
		+ "6 bond+10 | 7 corruption+15 | 8 revelation | 9 dread+20 | 0 reset\n"
		+ "K save | L load | E dig"
	)
