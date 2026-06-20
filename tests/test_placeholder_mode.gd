extends GutTest
## Placeholder mode is ADDITIVE + REVERSIBLE and VISUAL-ONLY: it must never
## change quest logic. These tests prove the skin/restore contract and that
## toggling it does not alter the Hollow House outcome (dig/unlock/journal/save).

const DiggableScene := preload("res://scenes/world/diggable_spot.tscn")
const DoorScript := preload("res://scripts/world/door_transition.gd")
const SearchScript := preload("res://scripts/world/searchable_clue.gd")

var _default_enabled: bool


func before_each() -> void:
	_default_enabled = PlaceholderMode.is_enabled()
	PlaceholderMode._restore()
	PlayerData.reset_to_defaults()
	Journal.reset()


func after_each() -> void:
	PlaceholderMode._restore()
	PlaceholderMode.enabled = _default_enabled  # leave the global as we found it


func _ph_children(n: Node) -> int:
	var c := 0
	for ch in n.get_children():
		if ch.is_in_group(PlaceholderKit.GROUP):
			c += 1
	return c


# --- convention (one source of truth) ---

func test_kit_distinct_colour_and_group_per_category() -> void:
	var seen := {}
	for cat in [PlaceholderKit.Cat.PLAYER, PlaceholderKit.Cat.COMPANION,
			PlaceholderKit.Cat.INTERACTABLE, PlaceholderKit.Cat.MONSTER, PlaceholderKit.Cat.PROP]:
		var p := PlaceholderKit.make(cat)
		assert_true(p.is_in_group(PlaceholderKit.GROUP), "stand-in joins the _placeholder group")
		assert_gt(p.polygon.size(), 2, "has a real polygon shape")
		assert_false(seen.has(p.color), "each category has a distinct colour")
		seen[p.color] = true
		p.free()


# --- reversible skin / restore ---

func test_skin_hides_originals_adds_stand_ins_then_restores() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var body := CharacterBody2D.new()
	body.add_to_group("player")
	var spr := AnimatedSprite2D.new()
	spr.name = "AnimatedSprite2D"
	body.add_child(spr)
	root.add_child(body)
	var prop := Sprite2D.new()
	prop.name = "Prop"
	root.add_child(prop)

	PlaceholderMode.skin_tree(root)
	assert_false(spr.visible, "player sprite hidden under placeholder mode")
	assert_eq(_ph_children(body), 1, "exactly one stand-in on the player body")
	assert_false(prop.visible, "prop sprite hidden")
	assert_eq(_ph_children(root), 1, "one prop stand-in (sibling)")

	PlaceholderMode._restore()
	assert_true(spr.visible, "player sprite restored — art is only hidden, never lost")
	assert_true(prop.visible, "prop restored")
	assert_true(PlaceholderMode._placeholders.is_empty(), "no tracked stand-ins remain")
	assert_true(PlaceholderMode._hidden.is_empty(), "nothing left hidden")


func test_interactable_groups_get_a_stand_in() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var spot: DiggableSpot = DiggableScene.instantiate()
	root.add_child(spot)  # joins group "diggable" on _ready
	PlaceholderMode.skin_tree(root)
	assert_eq(_ph_children(spot), 1, "diggable interactable gets a stand-in")
	PlaceholderMode._restore()


func test_skin_restore_skin_does_not_duplicate() -> void:
	var root := Node2D.new()
	add_child_autofree(root)
	var body := CharacterBody2D.new()
	body.add_to_group("player")
	var spr := AnimatedSprite2D.new()
	spr.name = "AnimatedSprite2D"
	body.add_child(spr)
	root.add_child(body)

	PlaceholderMode.skin_tree(root)
	PlaceholderMode._restore()
	await get_tree().process_frame  # let the queued_free stand-ins actually go
	PlaceholderMode.skin_tree(root)
	assert_eq(_ph_children(body), 1, "still exactly one stand-in after skin→restore→skin")
	PlaceholderMode._restore()


# --- the load-bearing guarantee: toggling does not change the quest outcome ---

func _run_quest_chain() -> Dictionary:
	var key_spot: DiggableSpot = DiggableScene.instantiate()
	add_child_autofree(key_spot)
	key_spot.spot_id = &"ph_buried_key"
	key_spot.dig_item = &"hollow_key"
	key_spot.reveal()
	var key_after_dig := Inventory.has(&"hollow_key")

	var door: DoorTransition = DoorScript.new()
	add_child_autofree(door)
	door.unlock_item_id = &"hollow_key"
	door.unlock_flag = &"ph_inner_unlocked"
	var locked_with_key := door.is_locked()
	door._apply_unlock()

	Journal.witness(&"sign_hollow_a", "x", Journal.Kind.DOOM)
	Journal.witness(&"sign_hollow_b", "x", Journal.Kind.DOOM)

	var book: SearchableClue = SearchScript.new()
	add_child_autofree(book)
	book.spot_id = &"hollow_house_ledger"
	book.lore_text = "x"
	book.marks_book_read = true
	book.search()

	return {
		"key_after_dig": key_after_dig,
		"locked_with_key": locked_with_key,
		"unlocked_flag": PlayerData.has_story_flag(&"ph_inner_unlocked"),
		"key_consumed": not Inventory.has(&"hollow_key"),
		"journal": Journal.has_entry(&"hollow_house_ledger"),
		"revelation": PlayerData.is_revelation_known(&"hollow_house_truth"),
	}


func test_toggle_does_not_change_quest_outcome() -> void:
	PlaceholderMode.set_enabled(false)
	var off := _run_quest_chain()

	PlayerData.reset_to_defaults()
	Journal.reset()

	PlaceholderMode.set_enabled(true)
	var on := _run_quest_chain()

	assert_eq(on, off, "identical quest outcome with placeholder mode ON vs OFF")
	# and the outcome is the real completed quest, not two matching failures
	assert_true(on["key_after_dig"], "dig yields the key")
	assert_false(on["locked_with_key"], "door opens with the key")
	assert_true(on["unlocked_flag"], "unlock persists")
	assert_true(on["key_consumed"], "key consumed on unlock")
	assert_true(on["journal"], "book writes the witnessed LORE entry")
	assert_true(on["revelation"], "recontext fires (gate met)")
