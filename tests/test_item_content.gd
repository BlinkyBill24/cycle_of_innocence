extends GutTest
## Item-content pass: the new inventory item defs (food / weapons / dig-up)
## load with art + correct fields, and DiggableSpot.dig_item grants on reveal.

const NEW_ITEMS := [
	&"forest_berries", &"sturdy_stick", &"slingshot",
	&"sling_stones", &"buried_bone", &"tin_locket",
]


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	PlayerData.reset_to_defaults()


## --- defs load with art ---

func test_all_new_item_defs_load() -> void:
	for id: StringName in NEW_ITEMS:
		var def: ItemDef = ItemRegistry.get_def(id)
		assert_not_null(def, "def loads: %s" % id)
		if def != null:
			assert_eq(def.id, id, "id matches filename stem: %s" % id)
			assert_not_null(def.icon, "icon assigned: %s" % id)


func test_dried_meat_now_has_icon() -> void:
	var def: ItemDef = ItemRegistry.get_def(&"dried_meat")
	assert_not_null(def)
	assert_not_null(def.icon, "dried_meat icon wired (was placeholder)")


func test_key_item_locket_is_non_discardable() -> void:
	var def: ItemDef = ItemRegistry.get_def(&"tin_locket")
	assert_not_null(def)
	assert_eq(def.category, ItemDef.Category.KEY, "tin_locket is a Key item")
	assert_false(def.discardable, "Key keepsake cannot be discarded")


func test_weapons_are_wired_for_combat() -> void:
	# Wired 2026-06-20 (Wiring & Audibility pass): stick = melee EQUIP,
	# slingshot = THROW spending sling_stones. Full combat logic in test_weapon_combat.gd.
	var stick: ItemDef = ItemRegistry.get_def(&"sturdy_stick")
	assert_eq(stick.use_kind, ItemDef.UseKind.EQUIP, "stick is an EQUIP (melee) weapon")
	var sling: ItemDef = ItemRegistry.get_def(&"slingshot")
	assert_eq(sling.use_kind, ItemDef.UseKind.THROW, "slingshot is a THROW weapon")
	assert_eq(sling.ammo_id, &"sling_stones", "slingshot ammo is sling_stones")
	var stones: ItemDef = ItemRegistry.get_def(&"sling_stones")
	assert_not_null(stones)
	assert_true(stones.stackable, "sling_stones stack as ammo")


## --- dig-up grant ---

func test_diggable_with_item_grants_on_reveal() -> void:
	watch_signals(GameEvents)
	var spot := DiggableSpot.new()
	spot.spot_id = &"test_dig_grant"
	spot.dig_item = &"buried_bone"
	add_child_autofree(spot)
	assert_true(spot.reveal(), "first reveal succeeds")
	assert_true(Inventory.has(&"buried_bone"), "dig granted the bone")
	assert_signal_emitted(GameEvents, "item_acquired")
	assert_signal_emitted(GameEvents, "diggable_revealed")


func test_diggable_without_item_grants_nothing() -> void:
	var spot := DiggableSpot.new()
	spot.spot_id = &"test_dig_lore_only"
	add_child_autofree(spot)
	assert_true(spot.reveal())
	assert_eq(Inventory.count(), 0, "lore-only dig adds no item")


func test_diggable_reveal_is_one_shot() -> void:
	var spot := DiggableSpot.new()
	spot.spot_id = &"test_dig_once"
	spot.dig_item = &"buried_bone"
	add_child_autofree(spot)
	assert_true(spot.reveal(), "first reveal true")
	assert_false(spot.reveal(), "second reveal false (no double-grant)")
	assert_eq(Inventory.quantity_of(&"buried_bone"), 1, "granted exactly once")
