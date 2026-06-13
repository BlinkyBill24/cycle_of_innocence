extends GutTest
## Journal of observed signs (secrets-and-discovery #5 / progression Journal):
## witnessed-only, idempotent, ordered, save round-trips. The "memory aid, not
## a checklist" contract — there is no API to add an unwitnessed/pending entry.

const DiggableSpotScript := preload("res://scripts/world/diggable_spot.gd")


func before_each() -> void:
	Journal.reset()


func after_each() -> void:
	Journal.reset()


func test_witness_records_once_and_is_idempotent() -> void:
	assert_eq(Journal.entry_count(), 0)
	assert_true(Journal.witness(&"toy_a", "A small stitched bear, half-buried."))
	assert_eq(Journal.entry_count(), 1)
	assert_true(Journal.has_entry(&"toy_a"))
	# witnessing the same sign again (re-enter zone, re-dig) does not duplicate
	assert_false(Journal.witness(&"toy_a", "different text, same id"))
	assert_eq(Journal.entry_count(), 1)


func test_empty_inputs_rejected() -> void:
	assert_false(Journal.witness(&"", "text"))
	assert_false(Journal.witness(&"id", ""))
	assert_eq(Journal.entry_count(), 0)


func test_newest_first_and_kind_filter() -> void:
	Journal.witness(&"lore1", "first", Journal.Kind.LORE)
	Journal.witness(&"doom1", "the wardens carry lanterns now", Journal.Kind.DOOM)
	Journal.witness(&"lore2", "second", Journal.Kind.LORE)
	var newest := Journal.entries_newest_first()
	assert_eq(String(newest[0]["id"]), "lore2", "most recent on top")
	assert_eq(String(newest[2]["id"]), "lore1", "oldest last")
	assert_eq(Journal.entries_of_kind(Journal.Kind.DOOM).size(), 1)
	assert_eq(Journal.entries_of_kind(Journal.Kind.LORE).size(), 2)


func test_save_round_trip() -> void:
	Journal.witness(&"lore1", "a buried toy", Journal.Kind.LORE)
	Journal.witness(&"doom1", "an empty bench", Journal.Kind.DOOM)
	var data := Journal.get_save_data()
	Journal.reset()
	assert_eq(Journal.entry_count(), 0)
	Journal.apply_save_data(data)
	assert_eq(Journal.entry_count(), 2)
	assert_true(Journal.has_entry(&"lore1"))
	assert_true(Journal.has_entry(&"doom1"))
	# kind survives the round trip
	assert_eq(int(Journal.entries_of_kind(Journal.Kind.DOOM)[0]["kind"]), Journal.Kind.DOOM)
	# re-applying is idempotent (no duplicate entries on double-load)
	Journal.apply_save_data(data)
	assert_eq(Journal.entry_count(), 2)


func test_emits_signal_on_new_entry() -> void:
	watch_signals(GameEvents)
	Journal.witness(&"lore1", "something")
	assert_signal_emitted_with_parameters(GameEvents, "journal_entry_added", [&"lore1"])


func test_dig_with_lore_writes_journal_entry() -> void:
	var spot: DiggableSpot = DiggableSpotScript.new()
	spot.spot_id = &"playground_buried_toy"
	spot.lore_text = "A wooden duck, paint flaked. Someone loved this."
	add_child_autofree(spot)
	assert_true(spot.reveal(), "first reveal succeeds")
	assert_true(Journal.has_entry(&"playground_buried_toy"),
		"the dig wrote a lore entry under the spot id")
	assert_eq(Journal.entry_count(), 1)
	# a mechanical dig (no lore_text) writes nothing
	var bare: DiggableSpot = DiggableSpotScript.new()
	bare.spot_id = &"mechanical_only"
	add_child_autofree(bare)
	bare.reveal()
	assert_eq(Journal.entry_count(), 1, "bare dig adds no journal entry")
