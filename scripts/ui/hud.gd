extends CanvasLayer
## Minimal slice HUD: heart row for HP (1 heart = 2 HP). Texture-based —
## text glyphs (♥) don't exist in the web export's fallback font.

const HP_PER_HEART := 2
const HEART_FULL := preload("res://assets/sprites/ui/heart_full.png")
const HEART_EMPTY := preload("res://assets/sprites/ui/heart_empty.png")
const HEART_DRAW_SIZE := Vector2(16, 16)

var _row: HBoxContainer
var _weapon: Label


func _ready() -> void:
	layer = 15
	_row = HBoxContainer.new()
	_row.position = Vector2(8, 6)
	_row.add_theme_constant_override("separation", 2)
	add_child(_row)
	# What Rowan is wielding — so the player can tell hands / stick / sling apart
	# (playtest: equipping was invisible). Plain Latin text renders in the web font.
	_weapon = Label.new()
	_weapon.position = Vector2(8, 26)
	_weapon.add_theme_font_size_override("font_size", 11)
	_weapon.add_theme_color_override("font_outline_color", Color.BLACK)
	_weapon.add_theme_constant_override("outline_size", 3)
	add_child(_weapon)
	if GameEvents:
		GameEvents.player_damaged.connect(func(hp: int, max_hp: int) -> void:
			_refresh(hp, max_hp))
		# equip/unequip emits item_used; ammo spend emits inventory_changed
		GameEvents.item_used.connect(func(_id: StringName) -> void: _refresh_weapon())
		GameEvents.inventory_changed.connect(_refresh_weapon)
	_refresh(PlayerData.current_hp, PlayerData.max_hp)
	_refresh_weapon()


## The currently wielded weapon line: "Bare hands" / "Sturdy Stick" /
## "Slingshot (5)" (throw weapons show ammo). Pure/testable.
static func weapon_label(def: ItemDef, ammo_qty: int) -> String:
	if def == null:
		return "Bare hands"
	if def.use_kind == ItemDef.UseKind.THROW:
		return "%s (%d)" % [def.display_name, maxi(ammo_qty, 0)]
	return def.display_name


func _refresh_weapon() -> void:
	if _weapon == null:
		return
	var id: StringName = PlayerData.equipped_weapon
	var def: ItemDef = ItemRegistry.get_def(id) if id != &"" else null
	var ammo: int = Inventory.quantity_of(def.ammo_id) if def != null and def.ammo_id != &"" else 0
	_weapon.text = weapon_label(def, ammo)


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
