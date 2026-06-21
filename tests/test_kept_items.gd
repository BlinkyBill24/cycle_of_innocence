extends GutTest
## Permanent ("Kept") items get their own satchel category (playtest 2026-06-21): a KEY
## item like the flute reads as something you HAVE, not lost among the consumable pockets.

const PanelScript := preload("res://scripts/ui/inventory_panel.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func test_is_kept_flags_only_key_items() -> void:
	assert_true(PanelScript.is_kept(ItemRegistry.get_def(&"flute")), "the flute is a kept item")
	assert_false(PanelScript.is_kept(ItemRegistry.get_def(&"sturdy_stick")),
		"a weapon stays in the bag, not Kept")
	assert_false(PanelScript.is_kept(null))


func test_kept_strip_shows_held_key_items() -> void:
	var panel: Node = PanelScript.new()
	add_child_autofree(panel)
	await wait_physics_frames(1)
	panel._refresh_kept(Inventory.slots())
	assert_eq(panel._kept_box.get_child_count(), 0, "nothing kept yet -> empty")
	assert_false(panel._kept_box.visible, "and the section hides when empty")
	Inventory.add(&"flute")
	panel._refresh_kept(Inventory.slots())
	assert_eq(panel._kept_box.get_child_count(), 1, "the flute appears in its own Kept category")
	assert_true(panel._kept_box.visible)
