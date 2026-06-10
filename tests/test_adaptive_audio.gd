extends GutTest
## AdaptiveAudio v2: exclusive crossfade selection (hysteresis), gain
## handover, and ducking (slice-gate "messy overlap" fix).

const AA := preload("res://scripts/autoload/adaptive_audio.gd")

var audio: Node


func before_each() -> void:
	DreadManager.reset()
	audio = AA.new()
	add_child_autofree(audio)
	audio.set_process(false)


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
