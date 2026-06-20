extends GutTest
## Weapon wiring (Wiring & Audibility pass): EQUIP (stick → melee swing) and
## THROW (slingshot → projectile, spends a sling_stone). Logic is unit-tested;
## the projectile spawn + swing visuals are F5 checks (agents are runtime-blind).

const PC := preload("res://scripts/player/player_controller.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


# --- EQUIP (sturdy_stick → melee) ---

func test_use_equips_weapon_without_consuming() -> void:
	assert_true(Inventory.add(&"sturdy_stick"), "stick added")
	assert_true(Inventory.use(&"sturdy_stick"), "use a weapon = equip it")
	assert_eq(PlayerData.equipped_weapon, &"sturdy_stick", "stick is now equipped")
	assert_true(Inventory.has(&"sturdy_stick"), "equipping does NOT consume the stick (reusable)")


func test_equipped_stick_swings_not_throws() -> void:
	var stick: ItemDef = ItemRegistry.get_def(&"sturdy_stick")
	assert_eq(stick.use_kind, ItemDef.UseKind.EQUIP, "stick is an EQUIP weapon")
	assert_false(PC.attack_is_throw(stick), "an equipped stick swings (melee), not throws")
	assert_false(PC.attack_is_throw(null), "bare hands swing too")


func test_equip_toggles_off() -> void:
	Inventory.add(&"sturdy_stick")
	Inventory.use(&"sturdy_stick")
	Inventory.use(&"sturdy_stick")  # tap the equipped weapon again
	assert_eq(PlayerData.equipped_weapon, &"", "re-using the equipped weapon unequips it")


# --- THROW (slingshot → projectile, spends sling_stones) ---

func test_slingshot_is_a_throw_weapon() -> void:
	var sling: ItemDef = ItemRegistry.get_def(&"slingshot")
	assert_eq(sling.use_kind, ItemDef.UseKind.THROW, "slingshot is a THROW weapon")
	assert_eq(sling.ammo_id, &"sling_stones", "its ammo is sling_stones")
	assert_true(PC.attack_is_throw(sling), "attacking with the slingshot throws")


func test_throw_decrements_the_stone_count() -> void:
	Inventory.add(&"sling_stones", 3)
	assert_true(PC.consume_throw_ammo(&"sling_stones"), "a throw with ammo succeeds")
	assert_eq(Inventory.quantity_of(&"sling_stones"), 2, "one stone spent per shot")


func test_throw_blocked_at_zero_stones() -> void:
	assert_eq(Inventory.quantity_of(&"sling_stones"), 0, "no stones to start")
	assert_false(PC.consume_throw_ammo(&"sling_stones"), "throw blocked with no ammo")
	assert_eq(Inventory.quantity_of(&"sling_stones"), 0, "nothing consumed when blocked")


func test_throw_blocked_without_ammo_id() -> void:
	assert_false(PC.consume_throw_ammo(&""), "a weapon with no ammo id can't throw")


# --- persistence ---

func test_equipped_weapon_survives_save_load() -> void:
	Inventory.add(&"slingshot")
	Inventory.use(&"slingshot")
	var data := PlayerData.get_save_data()
	PlayerData.reset_to_defaults()
	assert_eq(PlayerData.equipped_weapon, &"", "reset clears the equipped weapon")
	PlayerData.apply_save_data(data)
	assert_eq(PlayerData.equipped_weapon, &"slingshot", "equipped weapon restored on load")
