extends GutTest
## AdaptiveAudio v2: exclusive crossfade selection (hysteresis), gain
## handover, and ducking (slice-gate "messy overlap" fix).

const AA := preload("res://scripts/autoload/adaptive_audio.gd")

var audio: Node


var _threat: Node2D


func before_each() -> void:
	DreadManager.reset()
	audio = AA.new()
	add_child_autofree(audio)
	audio.set_process(false)
	# the cap_layer gate needs an actual threat for DANGER (tester-03 fix):
	# put a fake un-stilled enemy on top of a fake player
	var player := Node2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	_threat = Node2D.new()
	_threat.add_to_group("enemy")
	_threat.set("stilled", false)
	add_child_autofree(_threat)


func after_each() -> void:
	DreadManager.reset()


func test_layer_selection_with_hysteresis() -> void:
	# rising from ambient
	assert_eq(AA.select_layer(0.0, AA.Layer.AMBIENT), AA.Layer.AMBIENT)
	assert_eq(AA.select_layer(0.33, AA.Layer.AMBIENT), AA.Layer.TENSE)
	assert_eq(AA.select_layer(0.70, AA.Layer.AMBIENT), AA.Layer.DANGER)
	# hysteresis band: 0.28 keeps TENSE active but won't enter from AMBIENT
	assert_eq(AA.select_layer(0.28, AA.Layer.TENSE), AA.Layer.TENSE)
	assert_eq(AA.select_layer(0.28, AA.Layer.AMBIENT), AA.Layer.AMBIENT)
	# falling from danger
	assert_eq(AA.select_layer(0.60, AA.Layer.DANGER), AA.Layer.DANGER)
	assert_eq(AA.select_layer(0.50, AA.Layer.DANGER), AA.Layer.TENSE)
	assert_eq(AA.select_layer(0.10, AA.Layer.DANGER), AA.Layer.AMBIENT)


func test_exclusive_crossfade_hands_over() -> void:
	DreadManager.add_dread(90.0)  # presentation 0.9 -> danger
	for i in 80:  # ~8s of manual processing
		audio._process(0.1)
	assert_eq(audio._active, AA.Layer.DANGER)
	assert_almost_eq(float(audio._gains[AA.Layer.DANGER]), 1.0, 0.01, "danger fully in")
	assert_almost_eq(float(audio._gains[AA.Layer.AMBIENT]), 0.0, 0.01, "ambient fully out")
	var silent: float = audio._players[AA.Layer.AMBIENT].volume_db
	assert_lte(silent, -59.0, "inactive track is silenced, not layered")


func test_dwell_prevents_flapping() -> void:
	DreadManager.add_dread(40.0)  # tense territory
	audio._process(0.1)           # switches after initial dwell
	assert_eq(audio._active, AA.Layer.TENSE)
	DreadManager.reset()
	audio._process(0.1)           # dwell not yet elapsed
	assert_eq(audio._active, AA.Layer.TENSE, "no instant switch-back")


func test_duck_applies_and_recovers() -> void:
	audio.duck(12.0)
	audio._process(0.1)
	var ducked: float = audio._players[AA.Layer.AMBIENT].volume_db
	for i in 40:
		audio._process(0.1)
	var recovered: float = audio._players[AA.Layer.AMBIENT].volume_db
	assert_gt(recovered, ducked, "duck recovers over time")


func test_cap_layer_threat_and_daylight_gate() -> void:
	# tester-03: danger still audible after the monster was Stilled and in
	# bright daylight — the spec table needs combat/proximity, not dread alone
	assert_eq(AA.cap_layer(AA.Layer.DANGER, false, false, 0), AA.Layer.TENSE,
		"no threat, early stage: danger demotes to tense")
	assert_eq(AA.cap_layer(AA.Layer.DANGER, true, false, 0), AA.Layer.DANGER,
		"active threat keeps danger")
	assert_eq(AA.cap_layer(AA.Layer.DANGER, false, false, 2), AA.Layer.DANGER,
		"stage 2+ keeps danger even without proximity (the world IS the threat)")
	assert_eq(AA.cap_layer(AA.Layer.TENSE, false, true, 0), AA.Layer.AMBIENT,
		"bright day without threat: no gloom track")
	assert_eq(AA.cap_layer(AA.Layer.TENSE, true, true, 0), AA.Layer.TENSE,
		"threat overrides daylight")
	assert_eq(AA.cap_layer(AA.Layer.DANGER, false, true, 0), AA.Layer.AMBIENT,
		"no threat + bright day cascades danger all the way to ambient")
	assert_eq(AA.cap_layer(AA.Layer.AMBIENT, false, false, 0), AA.Layer.AMBIENT)
