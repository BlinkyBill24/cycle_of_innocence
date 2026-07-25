extends GutTest
## Agentic playtest smoke — **scene wiring** for the critical Hollow House path.
## Logic of dig → key → door → book → recontext lives in test_hollow_house.gd;
## this file fails fast if someone unplugs the world placements agents rely on
## for the MCP / tools/playtest_smoke.sh recipe.
## See docs/design/agentic-playtest-smoke.md.


func before_each() -> void:
	PlayerData.reset_to_defaults()
	Journal.reset()


# --- item registry: the key the door cares about still exists ---------------

func test_hollow_key_item_exists() -> void:
	assert_true(ItemRegistry.has_def(&"hollow_key"),
		"hollow_key.tres must resolve (door unlock + dig yield)")


# --- hollow house hall: buried key + item-gated inner door -----------------

func test_hollow_house_hall_wires_key_and_inner_door() -> void:
	var zone: Node = load("res://scenes/zones/hollow_house.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(2)

	var key_spot: DiggableSpot = null
	for node in get_tree().get_nodes_in_group("diggable"):
		var spot := node as DiggableSpot
		if spot and spot.spot_id == &"hollow_buried_key":
			key_spot = spot
			break
	# diggable group may be empty if the scene uses no group — fall back by name
	if key_spot == null:
		key_spot = zone.get_node_or_null("BuriedKey") as DiggableSpot
	assert_not_null(key_spot, "BuriedKey diggable is present in the hollow house hall")
	assert_eq(key_spot.dig_item, &"hollow_key", "digging the spot yields hollow_key")

	var door: DoorTransition = zone.get_node_or_null("InnerDoor") as DoorTransition
	assert_not_null(door, "InnerDoor transition exists")
	assert_eq(door.unlock_item_id, &"hollow_key", "inner door is gated by hollow_key")
	assert_eq(door.unlock_flag, &"hollow_inner_unlocked", "unlock persists via story flag")
	assert_eq(door.target_scene_path, "res://scenes/zones/hollow_house_back.tscn",
		"inner door leads to the back nook")


# --- back nook: flute + ledger path ----------------------------------------

func test_hollow_house_back_has_flute_and_ledger() -> void:
	var zone: Node = load("res://scenes/zones/hollow_house_back.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(2)

	var flute_found := false
	for node in get_tree().get_nodes_in_group("forage_spot"):
		var fs := node as ForageSpot
		if fs and fs.item_id == &"flute":
			flute_found = true
			break
	if not flute_found:
		# SceneState scan if forage_spot group is not set on the node
		var state: SceneState = (load("res://scenes/zones/hollow_house_back.tscn") as PackedScene).get_state()
		for i in state.get_node_count():
			for pi in state.get_node_property_count(i):
				if String(state.get_node_property_name(i, pi)) == "item_id" \
						and state.get_node_property_value(i, pi) == &"flute":
					flute_found = true
	assert_true(flute_found, "flute pickup is placed in the back nook")

	var book: SearchableClue = null
	for child in zone.get_children():
		if child is SearchableClue and (child as SearchableClue).spot_id == &"hollow_house_ledger":
			book = child as SearchableClue
			break
	assert_not_null(book, "ledger SearchableClue is in the back nook")
	assert_eq(book.revelation_id, &"hollow_house_truth",
		"ledger is wired to the hollow_house_truth revelation")


# --- village door into the house -------------------------------------------

func test_village_door_targets_hollow_house() -> void:
	var zone: Node = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(2)
	var door: DoorTransition = zone.get_node_or_null("HollowHouseDoor") as DoorTransition
	assert_not_null(door, "HollowHouseDoor exists on the village green")
	assert_eq(door.target_scene_path, "res://scenes/zones/hollow_house.tscn",
		"village door enters the hollow house")


# --- main slice scene boots without exploding ------------------------------

func test_main_playground_scene_survives_a_few_frames() -> void:
	var ps: PackedScene = load("res://scenes/zones/playground_fringes.tscn")
	assert_not_null(ps, "main playground_fringes scene loads")
	var inst: Node = ps.instantiate()
	assert_not_null(inst, "main scene instantiates")
	add_child_autofree(inst)
	await wait_physics_frames(4)
	assert_true(true, "main scene survived 4 physics frames (smoke boot)")


# --- end-to-end logic (mirrors test_hollow_house full path; keeps smoke 1-stop)

func test_smoke_quest_logic_dig_unlock_truth() -> void:
	var key_spot: DiggableSpot = load("res://scenes/world/diggable_spot.tscn").instantiate()
	add_child_autofree(key_spot)
	key_spot.spot_id = &"hollow_buried_key"
	key_spot.dig_item = &"hollow_key"
	assert_true(key_spot.reveal())
	assert_true(Inventory.has(&"hollow_key"))

	var door: DoorTransition = DoorTransition.new()
	add_child_autofree(door)
	door.unlock_item_id = &"hollow_key"
	door.unlock_flag = &"hollow_inner_unlocked"
	assert_false(door.is_locked())
	door._apply_unlock()
	assert_true(PlayerData.has_story_flag(&"hollow_inner_unlocked"))

	Journal.witness(&"sign_hollow_scratches", "x", Journal.Kind.DOOM)
	Journal.witness(&"sign_hollow_bowls", "x", Journal.Kind.DOOM)

	var book: SearchableClue = SearchableClue.new()
	add_child_autofree(book)
	book.spot_id = &"hollow_house_ledger"
	book.lore_text = "A water-stained ledger."
	book.journal_kind = Journal.Kind.LORE
	book.marks_book_read = true
	assert_true(book.search())
	assert_true(PlayerData.is_revelation_known(&"hollow_house_truth"),
		"smoke path completes: dig key → unlock → book + doom → truth")
