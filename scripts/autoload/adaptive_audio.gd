extends Node
## Adaptive audio v1 (docs/mechanics/adaptive-audio.md): three looping stems
## (ambient / tense / danger) crossfaded continuously from the dread level.
## Hollowing-stage and time-of-day inputs join post-slice.

const AMBIENT := preload("res://assets/audio/stems/playground_ambient.ogg")
const TENSE := preload("res://assets/audio/stems/playground_tense.ogg")
const DANGER := preload("res://assets/audio/stems/playground_danger.ogg")

const AMBIENT_DB := -8.0
const TENSE_MAX_DB := -6.0
const DANGER_MAX_DB := -4.0
const FADE_SPEED := 0.8  # linear gain per second

var _ambient: AudioStreamPlayer
var _tense: AudioStreamPlayer
var _danger: AudioStreamPlayer
var _tense_gain := 0.0
var _danger_gain := 0.0


func _ready() -> void:
	_ambient = _make_player(AMBIENT, AMBIENT_DB)
	_tense = _make_player(TENSE, -60.0)
	_danger = _make_player(DANGER, -60.0)


func _make_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	player.autoplay = true
	add_child(player)
	player.play()
	return player


func _process(delta: float) -> void:
	var presentation := DreadManager.get_presentation_strength()  # respects horror intensity
	var dread01 := presentation  # 0..1
	var tense_target := clampf(inverse_lerp(0.22, 0.55, dread01), 0.0, 1.0)
	var danger_target := clampf(inverse_lerp(0.58, 0.88, dread01), 0.0, 1.0)
	_tense_gain = move_toward(_tense_gain, tense_target, FADE_SPEED * delta)
	_danger_gain = move_toward(_danger_gain, danger_target, FADE_SPEED * delta)
	_tense.volume_db = _gain_to_db(_tense_gain, TENSE_MAX_DB)
	_danger.volume_db = _gain_to_db(_danger_gain, DANGER_MAX_DB)


func _gain_to_db(gain: float, max_db: float) -> float:
	if gain <= 0.001:
		return -60.0
	return linear_to_db(gain) + max_db
