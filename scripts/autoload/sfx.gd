extends Node
## Central one-shot SFX playback (pooled players). Placeholder streams from
## tools/gen_placeholder_sfx.py — swap files, keep names.

const STREAMS := {
	&"footstep": preload("res://assets/audio/sfx/footstep_grass.wav"),
	&"swing": preload("res://assets/audio/sfx/attack_swing.wav"),
	&"hit": preload("res://assets/audio/sfx/hit_thud.wav"),
	&"dig": preload("res://assets/audio/sfx/briar_dig.wav"),
	&"whimper": preload("res://assets/audio/sfx/briar_whimper.wav"),
	&"bark": preload("res://assets/audio/sfx/briar_bark.wav"),
	&"growl": preload("res://assets/audio/sfx/briar_growl.wav"),
	&"stinger_toy": preload("res://assets/audio/sfx/toy_creak_stinger.wav"),
	&"bell_toll": preload("res://assets/audio/sfx/hollowing_bell.wav"),
	&"lullaby": preload("res://assets/audio/stems/lullaby_motif.ogg"),
}
const POOL_SIZE := 8

var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	if GameEvents:
		GameEvents.combat_hit.connect(func(_faction: StringName, _amount: int) -> void:
			play(&"hit"))


func play(name: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.06) -> void:
	var stream: AudioStream = STREAMS.get(name)
	if stream == null:
		push_warning("Sfx: unknown sound '%s'" % name)
		return
	for player in _players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
			player.play()
			return
	# pool exhausted: steal the first player
	_players[0].stream = stream
	_players[0].volume_db = volume_db
	_players[0].play()


## Stop every pooled player currently playing the named sound.
func stop(name: StringName) -> void:
	var stream: AudioStream = STREAMS.get(name)
	if stream == null:
		return
	for player in _players:
		if player.playing and player.stream == stream:
			player.stop()
