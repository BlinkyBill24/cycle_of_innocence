extends GutTest
## Weapon legibility (playtest fixes): the HUD weapon line, the satchel tap-to-equip
## affordance, and per-weapon swing pitch. Pure helpers are unit-tested; the on-screen
## label/tint are F5 checks (agents are runtime-blind).

const HudScript := preload("res://scripts/ui/hud.gd")
const PanelScript := preload("res://scripts/ui/inventory_panel.gd")
const PC := preload("res://scripts/player/player_controller.gd")


# --- HUD weapon line ------------------------------------------------------

func test_weapon_label_reads_bare_hands_when_unarmed() -> void:
	assert_eq(HudScript.weapon_label(null, 0), "Bare hands")


func test_weapon_label_shows_melee_name() -> void:
	var stick: ItemDef = ItemRegistry.get_def(&"sturdy_stick")
	assert_eq(HudScript.weapon_label(stick, 0), "Sturdy Stick", "melee shows just its name")


func test_weapon_label_shows_throw_ammo_count() -> void:
	var sling: ItemDef = ItemRegistry.get_def(&"slingshot")
	assert_eq(HudScript.weapon_label(sling, 5), "Slingshot (5)", "throw weapon shows ammo left")
	assert_eq(HudScript.weapon_label(sling, 0), "Slingshot (0)", "out of stones still reads clearly")


# --- satchel affordance ---------------------------------------------------

func test_affordance_prompts_tap_to_equip_for_an_unequipped_weapon() -> void:
	var stick: ItemDef = ItemRegistry.get_def(&"sturdy_stick")
	assert_eq(PanelScript.weapon_affordance(stick, false), "Tap to equip")


func test_affordance_shows_equipped_state() -> void:
	var sling: ItemDef = ItemRegistry.get_def(&"slingshot")
	assert_eq(PanelScript.weapon_affordance(sling, true), "Equipped — tap to put it away")


func test_affordance_empty_for_non_weapons() -> void:
	var stones: ItemDef = ItemRegistry.get_def(&"sling_stones")  # use_kind NONE
	assert_eq(PanelScript.weapon_affordance(stones, false), "", "ammo/consumables aren't equippable")
	assert_eq(PanelScript.weapon_affordance(null, false), "", "an empty slot has no affordance")


# --- per-weapon swing pitch (audible distinction) -------------------------

func test_attack_pitch_distinguishes_hands_stick_sling() -> void:
	var stick: ItemDef = ItemRegistry.get_def(&"sturdy_stick")
	var sling: ItemDef = ItemRegistry.get_def(&"slingshot")
	assert_eq(PC.attack_pitch(null), 1.0, "bare hands sit in the middle")
	assert_lt(PC.attack_pitch(stick), 1.0, "a heavy branch lands lower")
	assert_gt(PC.attack_pitch(sling), 1.0, "the sling whips higher")
	assert_ne(PC.attack_pitch(stick), PC.attack_pitch(sling), "the three are audibly distinct")
