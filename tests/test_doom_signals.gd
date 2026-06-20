extends GutTest
## Doom signals + Journal wiring (doom-legibility roadmap + secrets arc):
## bell-pattern counting, WhisperSpot -> DOOM journal entry, DiggableSpot NG+
## recontextualization of lore fragments.

const WhisperScript := preload("res://scripts/world/whisper_spot.gd")
const DiggableScript := preload("res://scripts/world/diggable_spot.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()
	Journal.reset()
	HollowingClock.reset()
	DreadManager.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	Journal.reset()
	HollowingClock.reset()
	DreadManager.reset()


# --- bell pattern language ------------------------------------------------

func test_bell_pattern_spaces_tolls_so_they_can_be_counted() -> void:
	# toll i lands at i * gap; stage N rings N tolls, the last at (N-1)*gap
	assert_eq(HollowingClock.bell_pattern(0), 0.0, "first toll is immediate")
	assert_gt(HollowingClock.bell_pattern(1), 0.0, "later tolls are delayed")
	assert_gt(HollowingClock.bell_pattern(2), HollowingClock.bell_pattern(1),
		"tolls are monotonically spaced — countable")


# --- WhisperSpot writes a DOOM journal entry on witness -------------------

func _witness(spot: Node) -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	spot._on_body_entered(player)


func test_whisper_with_journal_text_records_doom_sign() -> void:
	var spot: WhisperSpot = WhisperScript.new()
	spot.spot_id = &"new_lottery_notice"
	spot.text = "A fresh notice, paste still wet."
	spot.journal_text = "They posted a new lottery notice already."
	add_child_autofree(spot)
	_witness(spot)
	assert_true(Journal.has_entry(&"sign_new_lottery_notice"),
		"witnessing the sign logged a journal entry")
	assert_eq(Journal.entries_of_kind(Journal.Kind.DOOM).size(), 1,
		"default whisper journal kind is DOOM")


func test_whisper_without_journal_text_logs_nothing() -> void:
	var spot: WhisperSpot = WhisperScript.new()
	spot.spot_id = &"atmosphere_only"
	spot.text = "just a whisper"
	add_child_autofree(spot)
	_witness(spot)
	assert_eq(Journal.entry_count(), 0)


# --- DiggableSpot NG+ recontextualization ---------------------------------

func test_choose_lore_swaps_when_revelation_known() -> void:
	assert_eq(DiggableScript.choose_lore("plain", "deeper", &"monsters_are_children"),
		"plain", "plain fragment before the revelation")
	PlayerData.unlock_revelation(&"monsters_are_children")
	assert_eq(DiggableScript.choose_lore("plain", "deeper", &"monsters_are_children"),
		"deeper", "recontextualized fragment once known (NG+ carries this)")


func test_choose_lore_no_recontext_text_stays_plain() -> void:
	PlayerData.unlock_revelation(&"monsters_are_children")
	assert_eq(DiggableScript.choose_lore("plain", "", &"monsters_are_children"),
		"plain", "no recontext variant authored -> plain")


func test_dig_logs_recontextualized_fragment_on_ngplus() -> void:
	PlayerData.unlock_revelation(&"monsters_are_children")  # as if carried into NG+
	var spot: DiggableSpot = DiggableScript.new()
	spot.spot_id = &"playground_buried_toy"
	spot.lore_text = "A stuffed rabbit. Tag: Mara — Harmony 71."
	spot.lore_text_recontext = "Mara's rabbit. She was the one before you."
	spot.recontext_revelation = &"monsters_are_children"
	add_child_autofree(spot)
	spot.reveal()
	var entries := Journal.entries_newest_first()
	assert_eq(entries.size(), 1)
	assert_string_contains(str(entries[0]["text"]), "the one before you",
		"NG+ dig logs the recontextualized fragment")


# --- fringes digs: NG+ second reads (shoe + duck) -------------------------
# The playground rabbit already carries its second read; these wire the same
# monsters_are_children gate onto the fringes shoe and duck.

func _fringes_digs() -> Dictionary:
	var zone: Node2D = load("res://scenes/zones/fringes.tscn").instantiate()
	add_child_autofree(zone)
	return {
		"shoe": zone.get_node("DiggableSpotFringes"),
		"duck": zone.get_node("StilledChildKeepsake"),
	}


func test_fringes_digs_first_read_until_the_truth_is_known() -> void:
	var digs := _fringes_digs()
	for key in digs:
		var spot: DiggableSpot = digs[key]
		assert_eq(spot.recontext_revelation, &"monsters_are_children",
			"%s uses the shared NG+ gate" % key)
		assert_false(spot.lore_text_recontext.is_empty(),
			"%s authors a second read" % key)
		assert_eq(DiggableScript.choose_lore(spot.lore_text, spot.lore_text_recontext,
			spot.recontext_revelation), spot.lore_text,
			"%s reads plainly before the revelation" % key)
	PlayerData.unlock_revelation(&"monsters_are_children")
	for key in digs:
		var spot: DiggableSpot = digs[key]
		assert_eq(DiggableScript.choose_lore(spot.lore_text, spot.lore_text_recontext,
			spot.recontext_revelation), spot.lore_text_recontext,
			"%s second-reads once the truth is known" % key)


func test_ngplus_gate_survives_save_round_trip() -> void:
	PlayerData.unlock_revelation(&"monsters_are_children")
	assert_true(SaveManager.save_game(97), "save writes")
	PlayerData.reset_to_defaults()
	assert_false(PlayerData.is_revelation_known(&"monsters_are_children"), "scrambled")
	assert_true(SaveManager.load_game(97, false), "load reads")
	assert_true(PlayerData.is_revelation_known(&"monsters_are_children"),
		"the NG+ second-read gate persists across save/load")
	SaveManager.delete_save(97)


func test_whisper_fires_for_already_overlapping_player() -> void:
	# recontext-gated whispers are disabled until the stage flips; an Area2D
	# does NOT emit body_entered for a body already inside when re-enabled.
	# The overlap poll must catch it (playtest 2026-06-13: doom sign never fired).
	var spot: WhisperSpot = WhisperScript.new()
	spot.spot_id = &"already_inside"
	spot.text = "."
	spot.journal_text = "logged via overlap poll"
	var shape := CollisionShape2D.new()
	var circ := CircleShape2D.new()
	circ.radius = 40.0
	shape.shape = circ
	spot.add_child(shape)
	add_child_autofree(spot)
	# a player body sitting ON the spot, never "entering" it
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	player.collision_layer = 2
	var pshape := CollisionShape2D.new()
	pshape.shape = CircleShape2D.new()
	player.add_child(pshape)
	add_child_autofree(player)
	player.global_position = spot.global_position
	await wait_physics_frames(3)
	assert_true(Journal.has_entry(&"sign_already_inside"),
		"overlap poll fired the journal entry for an already-present player")
