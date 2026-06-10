extends CanvasLayer
## Minimal slice HUD: heart row for HP (1 heart = 2 HP). Texture-based —
## text glyphs (♥) don't exist in the web export's fallback font.

const HP_PER_HEART := 2
const HEART_FULL := preload("res://assets/sprites/ui/heart_full.png")
const HEART_EMPTY := preload("res://assets/sprites/ui/heart_empty.png")
const HEART_DRAW_SIZE := Vector2(16, 16)

var _row: HBoxContainer


func _ready() -> void:
	layer = 15
	_row = HBoxContainer.new()
	_row.position = Vector2(8, 6)
	_row.add_theme_constant_override("separation", 2)
	add_child(_row)
	if GameEvents:
		GameEvents.player_damaged.connect(func(hp: int, max_hp: int) -> void:
			_refresh(hp, max_hp))
	_refresh(PlayerData.current_hp, PlayerData.max_hp)


func _refresh(hp: int, max_hp: int) -> void:
	var total := ceili(float(max_hp) / HP_PER_HEART)
	var full := ceili(float(hp) / HP_PER_HEART)
	while _row.get_child_count() < total:
		var heart := TextureRect.new()
		heart.custom_minimum_size = HEART_DRAW_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_row.add_child(heart)
	while _row.get_child_count() > total:
		_row.get_child(_row.get_child_count() - 1).queue_free()
	for i in _row.get_child_count():
		(_row.get_child(i) as TextureRect).texture = HEART_FULL if i < full else HEART_EMPTY
