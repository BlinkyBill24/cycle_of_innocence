extends GutTest
## Hollow House micro-quest — the pure/testable logic. The scene wiring, Briar-seek
## readability, dread ramp, and stinger timing are F5 checks (agents are
## runtime-blind). docs/design/hollow-house-quest.md.

const CompanionScript := preload("res://scripts/companions/companion_base.gd")
const QuestScript := preload("res://scripts/world/hollow_house_quest.gd")
const FearScript := preload("res://scripts/world/fear_emitter.gd")
const DiggableScene := preload("res://scenes/world/diggable_spot.tscn")


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
