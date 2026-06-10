extends CanvasLayer
## Minimal slice HUD: heart row for HP (1 heart = 2 HP). Listens to
## GameEvents.player_damaged; presentation only.

const HP_PER_HEART := 2
const FULL := "♥"
const EMPTY := "♡"

var _label: Label


func _ready() -> void:
	layer = 15
	_label = Label.new()
	_label.position = Vector2(8, 4)
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color(0.85, 0.25, 0.3))
	add_child(_label)
	if GameEvents:
		GameEvents.player_damaged.connect(func(hp: int, max_hp: int) -> void:
			_refresh(hp, max_hp))
	_refresh(PlayerData.current_hp, PlayerData.max_hp)


func _refresh(hp: int, max_hp: int) -> void:
	var total := ceili(float(max_hp) / HP_PER_HEART)
	var full := ceili(float(hp) / HP_PER_HEART)
	_label.text = FULL.repeat(full) + EMPTY.repeat(maxi(total - full, 0))
