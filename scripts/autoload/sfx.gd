extends Node
## Central one-shot SFX playback (pooled players). Most streams are real SFX
## from ElevenLabs (tools/gen_elevenlabs_sfx.py); growl/toy/bell/lullaby remain
## placeholder/other-source. Swap files, keep names.

## Emitted whenever a known sound is played — lets tests assert the audible
## wiring (e.g. one bell per stage advance, monster lunge plays the attack key).
signal played(name: StringName)

const STREAMS := {
	&"footstep": preload("res://assets/audio/sfx/footstep_grass.wav"),
	&"swing": preload("res://assets/audio/sfx/attack_swing.wav"),
	&"hit": preload("res://assets/audio/sfx/hit_thud.wav"),
	&"dig": preload("res://assets/audio/sfx/briar_dig.wav"),
	&"whimper": preload("res://assets/audio/sfx/briar_whimper.wav"),
	&"bark": preload("res://assets/audio/sfx/briar_bark.wav"),
	&"briar_seek": preload("res://assets/audio/sfx/briar_seek.wav"),  # exclusive seek-tell yip (companion-pointer)
	&"growl": preload("res://assets/audio/sfx/briar_growl.wav"),
	&"footstep_gravel": preload("res://assets/audio/sfx/footstep_gravel.wav"),
	&"found": preload("res://assets/audio/sfx/found.wav"),
	&"owl": preload("res://assets/audio/sfx/owl_hoot.wav"),
	&"church_bell": preload("res://assets/audio/sfx/church_bell.wav"),
	&"monster_attack": preload("res://assets/audio/sfx/monster_attack.wav"),
	&"monster_creep": preload("res://assets/audio/sfx/monster_creep.wav"),
	&"monster_hurt": preload("res://assets/audio/sfx/monster_hurt.wav"),
	&"stinger_toy": preload("res://assets/audio/sfx/toy_creak_stinger.wav"),
	&"bell_toll": preload("res://assets/audio/sfx/hollowing_bell.wav"),
	&"lullaby": preload("res://assets/audio/stems/lullaby_motif.ogg"),
	&"flute": preload("res://assets/audio/sfx/flute.wav"),  # diegetic one-shot Rowan plays to soothe (placeholder)
	&"eat": preload("res://assets/audio/sfx/eat.wav"),  # short munch on eating food (placeholder)
	&"door_locked": preload("res://assets/audio/sfx/door_locked.wav"),  # locked-door rattle + bolt thunk (ElevenLabs)
}
const POOL_SIZE := 8

## Per-sound base mix trim in dB, ADDED to the call-site volume_db — lets a hot
## source be tamed in one place (no asset re-encode, no per-call-site edits).
const VOLUMES := {
	&"bark": -8.0,  # ElevenLabs bark ran hot; pull it down everywhere it plays
}

var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	if GameEvents:
		GameEvents.combat_hit.connect(func(_faction: StringName, _amount: int) -> void:
			play(&"hit"))


func play(name: StringName, volume_db: float = 0.0, pitch_jitter: float = 0.06,
		base_pitch: float = 1.0) -> void:
	var stream: AudioStream = STREAMS.get(name)
	if stream == null:
		push_warning("Sfx: unknown sound '%s'" % name)
		return
	played.emit(name)
	var out_db: float = volume_db + float(VOLUMES.get(name, 0.0))
	# base_pitch lets one sound read as different weapons (heavy stick vs zippy
	# sling) without a new asset; jitter still varies each shot a touch.
	var pitch: float = maxf(0.05, base_pitch + randf_range(-pitch_jitter, pitch_jitter))
	for player in _players:
		if not player.playing:
			player.stream = stream
			player.volume_db = out_db
			player.pitch_scale = pitch
			player.play()
			return
	# pool exhausted: steal the first player
	_players[0].stream = stream
	_players[0].volume_db = out_db
	_players[0].pitch_scale = pitch
	_players[0].play()


## Stop every pooled player currently playing the named sound.
func stop(name: StringName) -> void:
	var stream: AudioStream = STREAMS.get(name)
	if stream == null:
		return
	for player in _players:
		if player.playing and player.stream == stream:
			player.stop()
