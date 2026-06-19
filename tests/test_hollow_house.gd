extends GutTest
## Hollow House micro-quest — the pure/testable logic. The scene wiring, Briar-seek
## readability, dread ramp, and stinger timing are F5 checks (agents are
## runtime-blind). docs/design/hollow-house-quest.md.

const CompanionScript := preload("res://scripts/companions/companion_base.gd")
const QuestScript := preload("res://scripts/world/hollow_house_quest.gd")
const FearScript := preload("res://scripts/world/fear_emitter.gd")
const DoorScript := preload("res://scripts/world/door_transition.gd")
const SearchScript := preload("res://scripts/world/searchable_clue.gd")
const DiggableScene := preload("res://scenes/world/diggable_spot.tscn")


func before_each() -> void:
	# isolate every test from quest/inventory/journal state the others leave behind
	PlayerData.reset_to_defaults()
	Journal.reset()


# --- Briar-seek target pick (pure) ---

func test_pick_seek_target_nearest_unfound() -> void:
	var cands := [
		{"pos": Vector2(100, 0), "found": false},
		{"pos": Vector2(10, 0), "found": false},
		{"pos": Vector2(5, 0), "found": true},  # closest, but found -> skipped
	]
	assert_eq(CompanionScript.pick_seek_target(cands, Vector2.ZERO), 1,
		"picks the nearest NOT-found candidate")


func test_pick_seek_target_all_found_returns_minus_one() -> void:
	assert_eq(CompanionScript.pick_seek_target([{"pos": Vector2(1, 0), "found": true}], Vector2.ZERO), -1)


func test_pick_seek_target_empty_returns_minus_one() -> void:
	assert_eq(CompanionScript.pick_seek_target([], Vector2.ZERO), -1)


# --- knowledge gate (pure): gate on witnessed DOOM, never item count ---

func test_knowledge_gate_counts_only_prefixed_doom() -> void:
	var doom := [
		{"id": "sign_hollow_scratches", "text": "x", "kind": 1},
		{"id": "sign_hollow_bowls", "text": "x", "kind": 1},
		{"id": "sign_playground_notice", "text": "x", "kind": 1},  # other zone -> ignored
	]
	assert_true(QuestScript.knowledge_gate_met(doom, "sign_hollow", 2),
		"two house signs meet threshold 2")
	assert_false(QuestScript.knowledge_gate_met(doom, "sign_hollow", 3),
		"only two house signs — three not met")


func test_knowledge_gate_below_threshold() -> void:
	assert_false(QuestScript.knowledge_gate_met(
		[{"id": "sign_hollow_scratches", "text": "x", "kind": 1}], "sign_hollow", 2))


# --- fear-emitter proximity curve (pure) ---

func test_fear_curve_peaks_at_target() -> void:
	assert_eq(FearScript.proximity_curve(0.0, 150.0), 1.0, "max dread at the truth")


func test_fear_curve_zero_at_edge() -> void:
	assert_eq(FearScript.proximity_curve(150.0, 150.0), 0.0, "no dread at the radius edge")


func test_fear_curve_ramps_inward() -> void:
	assert_gt(FearScript.proximity_curve(40.0, 150.0), FearScript.proximity_curve(120.0, 150.0),
		"dread ramps up as the player nears the hidden truth")


func test_fear_curve_zero_radius_safe() -> void:
	assert_eq(FearScript.proximity_curve(10.0, 0.0), 0.0, "no divide-by-zero")


# --- no-missable fallback: the ledger reveals WITHOUT Briar ---

func test_ledger_reveal_grants_lore_without_briar() -> void:
	var spot: DiggableSpot = DiggableScene.instantiate()
	add_child_autofree(spot)
	spot.spot_id = &"test_hollow_fallback"
	spot.lore_sign_id = &"test_hollow_fallback_lore"
	spot.lore_text = "A test ledger, no dog required."
	assert_false(Journal.has_entry(&"test_hollow_fallback_lore"), "not witnessed before the reveal")
	# no companion is in this tree — reveal() is the player-by-hand fallback path
	assert_true(spot.reveal(), "the book reveals with no Briar present")
	assert_true(Journal.has_entry(&"test_hollow_fallback_lore"),
		"the reveal itself writes the witnessed LORE entry")
	assert_false(spot.reveal(), "idempotent — a second reveal is a no-op")


# --- recontext lore choice (NG+ second read) ---

func test_ledger_recontext_lore_choice() -> void:
	var rev := &"test_hollow_truth"  # a test-only revelation id
	assert_eq(DiggableSpot.choose_lore("plain", "recontext", rev), "plain",
		"plain read while the truth is unknown")
	PlayerData.unlock_revelation(rev)
	assert_eq(DiggableSpot.choose_lore("plain", "recontext", rev), "recontext",
		"once the truth is known the recontextualized read is chosen")


func test_choose_lore_no_recontext_stays_plain() -> void:
	assert_eq(DiggableSpot.choose_lore("plain", "", &"anything"), "plain",
		"empty recontext text always yields the plain read")


# --- key gate: DoorTransition.compute_locked (pure) ---

func test_compute_locked_plain_door() -> void:
	assert_false(DoorScript.compute_locked(false, false, false, false),
		"an unlocked, un-gated door is open")
	assert_true(DoorScript.compute_locked(true, false, false, false),
		"a base-locked door blocks")


func test_compute_locked_item_gate() -> void:
	assert_true(DoorScript.compute_locked(false, true, false, false),
		"item-gated + no key -> locked")
	assert_false(DoorScript.compute_locked(false, true, true, false),
		"item-gated + key held -> open")


func test_compute_locked_already_unlocked_wins() -> void:
	assert_false(DoorScript.compute_locked(true, true, false, true),
		"once opened, the door stays open even with the key spent")


# --- key gate: is_locked + _apply_unlock on a live door (consumes the key) ---

func test_door_is_locked_with_and_without_key() -> void:
	assert_true(ItemRegistry.has_def(&"hollow_key"), "hollow_key.tres must resolve")
	var door: DoorTransition = DoorScript.new()
	add_child_autofree(door)
	door.unlock_item_id = &"hollow_key"
	door.unlock_flag = &"hollow_inner_unlocked"
	assert_true(door.is_locked(), "locked with no key in the satchel")
	Inventory.add(&"hollow_key")
	assert_false(door.is_locked(), "unlocked once the key is held")


func test_door_apply_unlock_consumes_key_and_persists() -> void:
	var door: DoorTransition = DoorScript.new()
	add_child_autofree(door)
	door.unlock_item_id = &"hollow_key"
	door.unlock_flag = &"hollow_inner_unlocked"
	Inventory.add(&"hollow_key")
	door._apply_unlock()
	assert_true(PlayerData.has_story_flag(&"hollow_inner_unlocked"),
		"unlock is recorded as a persistent flag (survives save/load)")
	assert_false(Inventory.has(&"hollow_key"), "the key is spent on first unlock")
	assert_false(door.is_locked(), "still open after the key is consumed (flag wins)")


# --- buried key: a DiggableSpot yields hollow_key ---

func test_diggable_yields_hollow_key() -> void:
	var spot: DiggableSpot = DiggableScene.instantiate()
	add_child_autofree(spot)
	spot.spot_id = &"test_buried_key"
	spot.dig_item = &"hollow_key"
	assert_false(Inventory.has(&"hollow_key"), "no key before the dig")
	assert_true(spot.reveal(), "first reveal succeeds")
	assert_true(Inventory.has(&"hollow_key"), "the dig unearths the tarnished key")


# --- book: SearchableClue writes a witnessed LORE entry exactly once ---

func test_searchable_writes_lore_once() -> void:
	var book: SearchableClue = SearchScript.new()
	add_child_autofree(book)
	book.spot_id = &"test_book_lore"
	book.lore_text = "A test primer, read once."
	book.journal_kind = Journal.Kind.LORE
	# no dialogue_path -> no balloon await; search() stays synchronous
	assert_true(book.search(), "first search reveals the clue")
	assert_true(Journal.has_entry(&"test_book_lore"), "the search wrote the LORE entry")
	assert_eq(Journal.entry_count(), 1, "exactly one entry")
	assert_false(book.search(), "idempotent — a second search is a no-op")
	assert_eq(Journal.entry_count(), 1, "no duplicate entry")


# --- recontext gate: try_fire needs BOTH the book read AND the doom threshold ---

func test_try_fire_needs_book_read() -> void:
	Journal.witness(&"sign_hollow_a", "x", Journal.Kind.DOOM)
	Journal.witness(&"sign_hollow_b", "x", Journal.Kind.DOOM)
	# doom met, but the book is unread
	assert_false(QuestScript.try_fire(&"hollow_house_truth", "sign_hollow", 2, &"hollow_book_read"),
		"doom witnessed but book unread -> no recontext")
	assert_false(PlayerData.is_revelation_known(&"hollow_house_truth"))


func test_try_fire_needs_doom_threshold() -> void:
	PlayerData.set_story_flag(&"hollow_book_read")
	Journal.witness(&"sign_hollow_a", "x", Journal.Kind.DOOM)  # only one sign
	assert_false(QuestScript.try_fire(&"hollow_house_truth", "sign_hollow", 2, &"hollow_book_read"),
		"book read but only one doom sign -> below threshold")


func test_try_fire_completes_and_is_idempotent() -> void:
	PlayerData.set_story_flag(&"hollow_book_read")
	Journal.witness(&"sign_hollow_a", "x", Journal.Kind.DOOM)
	Journal.witness(&"sign_hollow_b", "x", Journal.Kind.DOOM)
	assert_true(QuestScript.try_fire(&"hollow_house_truth", "sign_hollow", 2, &"hollow_book_read"),
		"book read + two doom signs -> the truth lands")
	assert_true(PlayerData.is_revelation_known(&"hollow_house_truth"))
	assert_false(QuestScript.try_fire(&"hollow_house_truth", "sign_hollow", 2, &"hollow_book_read"),
		"idempotent — the revelation fires only once")


# --- full path (logic smoke): dig key -> unlock -> read book -> recontext ---

func test_full_quest_path_smoke() -> void:
	# 1) Briar/Rowan dig the buried key in the hall
	var key_spot: DiggableSpot = DiggableScene.instantiate()
	add_child_autofree(key_spot)
	key_spot.spot_id = &"hollow_buried_key"
	key_spot.dig_item = &"hollow_key"
	assert_true(key_spot.reveal(), "the key is unearthed")
	assert_true(Inventory.has(&"hollow_key"))

	# 2) the inner door reads as unlocked, then consumes the key on passage
	var door: DoorTransition = DoorScript.new()
	add_child_autofree(door)
	door.unlock_item_id = &"hollow_key"
	door.unlock_flag = &"hollow_inner_unlocked"
	assert_false(door.is_locked(), "key in hand -> door open")
	door._apply_unlock()
	assert_true(PlayerData.has_story_flag(&"hollow_inner_unlocked"))
	assert_false(Inventory.has(&"hollow_key"), "key spent")

	# 3) the player has witnessed the hall's doom-signals on the way
	Journal.witness(&"sign_hollow_scratches", "x", Journal.Kind.DOOM)
	Journal.witness(&"sign_hollow_bowls", "x", Journal.Kind.DOOM)

	# 4) reading the ledger in the nook fires the recontextualization beat
	var book: SearchableClue = SearchScript.new()
	add_child_autofree(book)
	book.spot_id = &"hollow_house_ledger"
	book.lore_text = "A water-stained ledger."
	book.journal_kind = Journal.Kind.LORE
	book.marks_book_read = true
	assert_true(book.search(), "the ledger is read")
	assert_true(PlayerData.has_story_flag(&"hollow_book_read"))
	assert_true(PlayerData.is_revelation_known(&"hollow_house_truth"),
		"book read + doom threshold -> the truth is known (quest complete)")


# --- scene wiring smoke: both halls instantiate with all scripts/resources ---

func test_hollow_house_scene_wired() -> void:
	var ps: PackedScene = load("res://scenes/zones/hollow_house.tscn")
	assert_not_null(ps, "hollow_house.tscn loads")
	var inst: Node = ps.instantiate()  # compiles every script, resolves every ext_resource
	assert_not_null(inst.get_node_or_null("InnerDoor"), "key-gated inner door present")
	assert_not_null(inst.get_node_or_null("BuriedKey"), "buried key dig spot present")
	assert_not_null(inst.get_node_or_null("SpawnFromBack"), "return marker from the nook present")
	var door := inst.get_node_or_null("InnerDoor") as DoorTransition
	assert_eq(door.unlock_item_id, &"hollow_key", "inner door gates on the key")
	var exit := inst.get_node_or_null("ExitDoor") as DoorTransition
	assert_eq(exit.target_path(), "res://scenes/zones/village_green.tscn",
		"exit lands in the village green")
	inst.free()


func test_hollow_house_back_scene_wired() -> void:
	var ps: PackedScene = load("res://scenes/zones/hollow_house_back.tscn")
	assert_not_null(ps, "hollow_house_back.tscn loads")
	var inst: Node = ps.instantiate()
	var book := inst.get_node_or_null("Ledger") as SearchableClue
	assert_not_null(book, "the ledger/book is in the nook")
	assert_true(book.marks_book_read, "reading the ledger drives the recontext beat")
	assert_not_null(inst.get_node_or_null("SpawnDefault"), "nook entry marker present")
	var exit := inst.get_node_or_null("ExitDoor") as DoorTransition
	assert_eq(exit.spawn_id, &"from_back", "nook exit returns to the hall's back marker")
	inst.free()
