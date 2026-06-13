extends GutTest
## Inventory vertical slice: ItemDef/ItemRegistry catalogue, Inventory verbs
## (add/remove/use), demo care-food bond payoff on Briar, and save/load
## round-trip via PlayerData (mirrors test_save_manager.gd).
##
## Inventory and ItemRegistry are global class_name statics (like
## CompanionQuirkDefs) — callable without autoload registration.

const SLOT := 9  # test slot, never user slot 0

const DRIED_MEAT := &"dried_meat"
const RITUAL_FRAGMENT := &"ritual_fragment"


func before_each() -> void:
	PlayerData.reset_to_defaults()


func after_each() -> void:
	SaveManager.delete_save(SLOT)
	PlayerData.reset_to_defaults()


## --- add ---

func test_add_item_below_max_capacity_succeeds() -> void:
	watch_signals(GameEvents)
	assert_true(Inventory.add(DRIED_MEAT), "add returns true")
	assert_true(Inventory.has(DRIED_MEAT))
	assert_eq(Inventory.count(), 1, "one slot used")
	assert_signal_emitted(GameEvents, "item_acquired")
	assert_signal_emitted(GameEvents, "inventory_changed")


func test_add_item_at_max_capacity_fails() -> void:
	# Fill 10 distinct non-stackable slots with the Key item.
	for i in Inventory.MAX_SLOTS:
		Inventory.add(RITUAL_FRAGMENT)
	assert_eq(Inventory.count(), Inventory.MAX_SLOTS, "10 slots full")
	watch_signals(GameEvents)
	assert_false(Inventory.add(DRIED_MEAT), "11th add rejected")
	assert_eq(Inventory.count(), Inventory.MAX_SLOTS, "still 10 slots")
	assert_signal_emitted_with_parameters(
		GameEvents, "item_add_failed", [DRIED_MEAT, &"inventory_full"])


func test_add_unknown_item_fails() -> void:
	watch_signals(GameEvents)
	assert_false(Inventory.add(&"nonexistent_item_xyz"))
	assert_signal_emitted_with_parameters(
		GameEvents, "item_add_failed", [&"nonexistent_item_xyz", &"unknown_item"])
	assert_signal_not_emitted(GameEvents, "item_acquired")


func test_stackable_increments_quantity() -> void:
	Inventory.add(DRIED_MEAT)
	Inventory.add(DRIED_MEAT)
	assert_eq(Inventory.count(), 1, "stacks into one slot")
	assert_eq(Inventory.quantity_of(DRIED_MEAT), 2)


## --- remove ---

func test_remove_item_succeeds() -> void:
	Inventory.add(DRIED_MEAT)
	watch_signals(GameEvents)
	assert_true(Inventory.remove(DRIED_MEAT))
	assert_false(Inventory.has(DRIED_MEAT))
	assert_signal_emitted(GameEvents, "item_discarded")
	assert_signal_emitted(GameEvents, "inventory_changed")


func test_remove_nonexistent_fails() -> void:
	watch_signals(GameEvents)
	assert_false(Inventory.remove(DRIED_MEAT))
	assert_signal_not_emitted(GameEvents, "item_discarded")


func test_key_item_cannot_be_removed() -> void:
	Inventory.add(RITUAL_FRAGMENT)
	assert_false(Inventory.remove(RITUAL_FRAGMENT), "Key item refuses discard")
	assert_true(Inventory.has(RITUAL_FRAGMENT), "still present")


## --- use (demo bond payoff) ---

func test_use_companion_care_item_updates_bond() -> void:
	# Briar starts at the slice baseline of 25.0.
	assert_eq(PlayerData.get_companion(&"briar").bond, 25.0, "baseline")
	Inventory.add(DRIED_MEAT)
	watch_signals(GameEvents)
	assert_true(Inventory.use(DRIED_MEAT))
	assert_eq(PlayerData.get_companion(&"briar").bond, 33.0, "+8 bond")
	assert_eq(PlayerData.morality, -3.0, "-3 morality flavor")
	assert_signal_emitted(GameEvents, "item_used")
	assert_eq(Inventory.quantity_of(DRIED_MEAT), 0, "consumed")
	assert_false(Inventory.has(DRIED_MEAT), "slot freed")


func test_demo_item_food_gives_correct_bond_delta() -> void:
	Inventory.add(DRIED_MEAT)
	Inventory.use(DRIED_MEAT)
	# Exact payoff the slice promises: 25.0 baseline -> 33.0.
	assert_eq(PlayerData.get_companion(&"briar").bond, 33.0)


func test_use_emits_item_used_before_consume() -> void:
	# A listener reading state on item_used must still see the item present.
	Inventory.add(DRIED_MEAT)
	var qty_at_signal := [-1]
	GameEvents.item_used.connect(
		func(_id: StringName) -> void: qty_at_signal[0] = Inventory.quantity_of(DRIED_MEAT),
		CONNECT_ONE_SHOT)
	Inventory.use(DRIED_MEAT)
	assert_eq(qty_at_signal[0], 1, "item still in satchel when item_used fired")
	assert_eq(Inventory.quantity_of(DRIED_MEAT), 0, "consumed after")


## --- persistence ---

func test_inventory_persists_on_save_load() -> void:
	Inventory.add(DRIED_MEAT)
	Inventory.add(DRIED_MEAT)
	Inventory.add(RITUAL_FRAGMENT)
	assert_true(SaveManager.save_game(SLOT))

	PlayerData.reset_to_defaults()
	assert_eq(Inventory.count(), 0, "cleared before load")

	assert_true(SaveManager.load_game(SLOT, false))
	assert_true(Inventory.has(DRIED_MEAT), "stackable restored")
	assert_eq(Inventory.quantity_of(DRIED_MEAT), 2, "quantity (int) survives JSON")
	assert_true(Inventory.has(RITUAL_FRAGMENT), "key item restored")
	# StringName re-wrap: the slot id must compare equal to a StringName.
	for slot: Dictionary in PlayerData.inventory:
		assert_typeof(slot["id"], TYPE_STRING_NAME)


func test_reset_to_defaults_clears_inventory() -> void:
	Inventory.add(DRIED_MEAT)
	PlayerData.lore_items.append(&"stub_lore")
	PlayerData.reset_to_defaults()
	assert_eq(Inventory.count(), 0)
	assert_true(PlayerData.lore_items.is_empty())


## --- registry / resources ---

func test_item_resource_loads_and_validates() -> void:
	var def: ItemDef = ItemRegistry.get_def(DRIED_MEAT)
	assert_not_null(def, "dried_meat .tres loads")
	assert_eq(def.category, ItemDef.Category.COMPANION_CARE)
	assert_eq(def.companion_id, &"briar")
	assert_eq(def.bond_delta, 8.0)
	assert_eq(def.use_kind, ItemDef.UseKind.FEED_COMPANION)
	assert_true(def.stackable)

	var key: ItemDef = ItemRegistry.get_def(RITUAL_FRAGMENT)
	assert_not_null(key)
	assert_eq(key.category, ItemDef.Category.KEY)
	assert_false(key.discardable, "key item non-discardable")


func test_all_ids_includes_demo_items() -> void:
	var ids: Array[StringName] = ItemRegistry.all_ids()
	assert_has(ids, DRIED_MEAT)
	assert_has(ids, RITUAL_FRAGMENT)


func test_morality_flavor_description_swaps() -> void:
	var def: ItemDef = ItemRegistry.get_def(DRIED_MEAT)
	# INNOCENT/WOUNDED -> caring base text.
	PlayerData.morality = 0.0
	assert_eq(def.read_description(), def.description, "base text below HARDENED")
	# Push to VESSEL tier (>80) -> colder distorted text. Effects unchanged.
	PlayerData.morality = 95.0
	assert_eq(PlayerData.get_morality_tier(), PlayerData.MoralityTier.VESSEL)
	assert_eq(def.read_description(), def.distorted_description, "distorted at VESSEL")
