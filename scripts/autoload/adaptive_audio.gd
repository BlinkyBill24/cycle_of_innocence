extends Node
## Adaptive audio v2 (slice-gate fix): EXCLUSIVE crossfade between intensity
## tracks instead of layering. The ACE-Step tracks are independent
## compositions — stacking them clashed ("messy/overlapped"). One track is
## audible at a time, with equal-power crossfades, hysteresis + dwell so the
## score doesn't flap at thresholds, and ducking under stingers/the lullaby.

enum Layer { AMBIENT, TENSE, DANGER, HIDEOUT }

const STREAMS := {
	Layer.AMBIENT: preload("res://assets/audio/stems/playground_ambient.ogg"),
	Layer.TENSE: preload("res://assets/audio/stems/playground_tense.ogg"),
	Layer.DANGER: preload("res://assets/audio/stems/playground_danger.ogg"),
	Layer.HIDEOUT: preload("res://assets/audio/stems/hideout_warm.ogg"),
}
const BASE_DB := {Layer.AMBIENT: -8.0, Layer.TENSE: -7.0, Layer.DANGER: -5.0, Layer.HIDEOUT: -6.0}

# hysteresis thresholds on dread presentation strength (0..1)
const UP_TENSE := 0.32
const DOWN_TENSE := 0.24
const UP_DANGER := 0.66
const DOWN_DANGER := 0.56

const CROSSFADE_TIME := 2.5  # seconds for a full handover
const MIN_DWELL := 4.0       # seconds before another switch is allowed
const DUCK_RECOVERY_DB_PER_S := 5.0
const SILENT_DB := -60.0

## Night ambience (Wiring & Audibility pass): a quiet always-on crickets bed
## under the score, plus an occasional owl stinger. Owls hush near a threat.
const CRICKETS := preload("res://assets/audio/sfx/crickets.wav")
const CRICKETS_DB := -22.0
const OWL_DB := -12.0
const OWL_MIN_GAP := 18.0
const OWL_MAX_GAP := 40.0

var _crickets: AudioStreamPlayer
var _owl_timer := 0.0
var _owl_next := 24.0

var _players: Dictionary = {}
var _gains: Dictionary = {}      # layer -> 0..1 crossfade weight
var _active: Layer = Layer.AMBIENT
var _dwell: float = MIN_DWELL
var _duck_db: float = 0.0


func _ready() -> void:
	for layer: Layer in STREAMS:
		var player := AudioStreamPlayer.new()
		player.stream = STREAMS[layer]
		player.volume_db = SILENT_DB
		add_child(player)
		player.play()
		_players[layer] = player
		_gains[layer] = 1.0 if layer == Layer.AMBIENT else 0.0
	if GameEvents:
		GameEvents.horror_stinger.connect(func(_trigger: StringName) -> void: duck(12.0))
	# the crickets night bed — quiet, always under the score (looped even if the
	# import-loop flag isn't picked up, via the finished->play reconnect)
	_crickets = AudioStreamPlayer.new()
	_crickets.stream = CRICKETS
	_crickets.volume_db = CRICKETS_DB
	add_child(_crickets)
	_crickets.finished.connect(_crickets.play)
	_crickets.play()


var _in_hideout := false


## Campfire override: the warm stem takes the channel while inside.
func set_hideout(inside: bool) -> void:
	_in_hideout = inside
	_dwell = MIN_DWELL  # allow the handover immediately


func _process(delta: float) -> void:
	_dwell += delta
	var target: int
	if _in_hideout:
		target = Layer.HIDEOUT
	else:
		var base := _active if _active != Layer.HIDEOUT else Layer.AMBIENT
		target = select_layer(DreadManager.get_presentation_strength(), base)
		target = cap_layer(target, _threat_active(),
				WorldState.time_of_day == WorldState.TimeOfDay.DAY,
				HollowingClock.stage)
	if target != _active and _dwell >= MIN_DWELL:
		_active = target as Layer
		_dwell = 0.0
	_duck_db = maxf(_duck_db - DUCK_RECOVERY_DB_PER_S * delta, 0.0)
	for layer: Layer in _players:
		var goal := 1.0 if layer == _active else 0.0
		_gains[layer] = move_toward(_gains[layer], goal, delta / CROSSFADE_TIME)
		_apply(layer)
	_owl_timer += delta
	if owl_due(_owl_timer, _owl_next, _in_hideout, _active):
		Sfx.play(&"owl", OWL_DB)
		_owl_timer = 0.0
		_owl_next = randf_range(OWL_MIN_GAP, OWL_MAX_GAP)


## Occasional night owl: fires on its timer, but never in the hideout and never
## while danger owns the channel (owls go quiet near a threat). Pure, testable.
static func owl_due(timer: float, next: float, in_hideout: bool, active: int) -> bool:
	return timer >= next and not in_hideout and active != Layer.DANGER


## Momentarily lower the music (stingers, the soothe lullaby) — recovers
## automatically at DUCK_RECOVERY_DB_PER_S.
func duck(amount_db: float = 10.0) -> void:
	_duck_db = maxf(_duck_db, amount_db)


const THREAT_RADIUS := 160.0  # tester-04: 220 kept danger alive too long past visibility


## Spec gate (mechanics/adaptive-audio.md stem table; playtest tester-03:
## danger kept playing after the monster was Stilled and in bright daylight).
## Danger needs an actual threat or late hollowing; bright day with no
## threat stays ambient. Pure, static for testability.
static func cap_layer(layer: int, threat: bool, bright_day: bool, stage: int) -> int:
	var capped := layer
	if capped == Layer.DANGER and not threat and stage < 2:
		capped = Layer.TENSE
	if capped == Layer.TENSE and bright_day and not threat:
		capped = Layer.AMBIENT
	return capped


## An un-stilled, un-dominated enemy near the player = active threat.
func _threat_active() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return false
	for node in get_tree().get_nodes_in_group("enemy"):
		var enemy := node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		var stilled_v: Variant = enemy.get("stilled")
		var dominated_v: Variant = enemy.get("dominated")
		if stilled_v == true or dominated_v == true:
			continue
		if enemy.global_position.distance_to(player.global_position) <= THREAT_RADIUS:
			return true
	return false


## Pure + hysteretic: which track should play for this dread strength,
## given the currently active one. Static for testability.
static func select_layer(strength: float, current: int) -> int:
	match current:
		Layer.TENSE:
			if strength >= UP_DANGER:
				return Layer.DANGER
			if strength <= DOWN_TENSE:
				return Layer.AMBIENT
			return Layer.TENSE
		Layer.DANGER:
			if strength <= DOWN_TENSE:
				return Layer.AMBIENT
			if strength <= DOWN_DANGER:
				return Layer.TENSE
			return Layer.DANGER
		_:
			if strength >= UP_DANGER:
				return Layer.DANGER
			if strength >= UP_TENSE:
				return Layer.TENSE
			return Layer.AMBIENT


func _apply(layer: Layer) -> void:
	var gain: float = _gains[layer]
	var player: AudioStreamPlayer = _players[layer]
	if gain <= 0.001:
		player.volume_db = SILENT_DB
		return
	# equal-power crossfade: amplitude follows sqrt(gain)
	player.volume_db = BASE_DB[layer] + linear_to_db(sqrt(gain)) - _duck_db
