extends Node
## The Hollowing Clock (docs/mechanics/hollowing-clock.md): event-driven doom
## escalation — the village's delayed alarm, mechanized. Stages advance on
## story milestones; player "noise" (loud kills, betrayal, domination) adds
## Alarm points that pull the next stage early, mercy subtracts them. Never
## advances mid-dialogue or inside the hideout (queued, fires on resume).
## No timer, no UI: the world tells you — bells, dread, Briar's unease.

signal stage_advanced(stage: int)

enum Stage { QUIET, DOUBT, ALARM, FRENZY, HOLLOWING }

const STAGE_MAX: int = Stage.HOLLOWING
const ALARM_THRESHOLD := 100.0
const RE_AGGRO_STAGE: int = Stage.FRENZY  # mercy comes undone — the horror
const NIGHT_FLOOR_PER_STAGE := 5.0
const STAGE_DREAD_HIT := 12.0

## Player noise (advancement rules: ruthless/loud accelerates, mercy delays).
const POINTS_KILL := 25.0
const POINTS_BETRAYAL := 40.0
const POINTS_DOMINATION := 35.0
const POINTS_MERCY := -20.0

var stage: int = Stage.QUIET
var alarm_points: float = 0.0
var _pending: int = 0
var _dialogue_open := false
var _in_hideout := false
var _milestones: Array[StringName] = []


func _ready() -> void:
	if GameEvents == null:
		return
	GameEvents.enemy_died.connect(func(_kind: StringName) -> void: add_alarm(POINTS_KILL))
	GameEvents.stilled_monster_killed.connect(func(_id: StringName) -> void: add_alarm(POINTS_BETRAYAL))
	GameEvents.monster_dominated.connect(func(_id: StringName) -> void: add_alarm(POINTS_DOMINATION))
	GameEvents.monster_stilled.connect(func(_id: StringName) -> void: add_alarm(POINTS_MERCY))
	GameEvents.revelation_unlocked.connect(func(id: StringName) -> void:
		register_milestone(StringName("revelation_" + String(id))))
	GameEvents.age_advanced.connect(func(new_age: int) -> void:
		if new_age > PlayerData.AgeStage.CHILD:  # growing up IS time passing
			register_milestone(StringName("age_" + str(new_age))))
	GameEvents.exploration_paused.connect(func() -> void: _dialogue_open = true)
	GameEvents.exploration_resumed.connect(func() -> void:
		_dialogue_open = false
		_fire_pending())
	GameEvents.hideout_entered.connect(func() -> void: _in_hideout = true)
	GameEvents.hideout_exited.connect(func() -> void:
		_in_hideout = false
		_fire_pending())


## Story milestones are the primary driver — each unique id is one stage.
func register_milestone(id: StringName) -> bool:
	if id in _milestones or stage >= STAGE_MAX:
		return false
	_milestones.append(id)
	_pending += 1
	_fire_pending()
	return true


func add_alarm(points: float) -> void:
	if stage >= STAGE_MAX:
		return
	alarm_points = maxf(alarm_points + points, 0.0)
	while alarm_points >= ALARM_THRESHOLD:
		alarm_points -= ALARM_THRESHOLD
		_pending += 1
	_fire_pending()


## Edge case (doc): never mid-dialogue or mid-care-scene — queue and fire.
func is_blocked() -> bool:
	return _dialogue_open or _in_hideout


func _fire_pending() -> void:
	while _pending > 0 and not is_blocked() and stage < STAGE_MAX:
		_pending -= 1
		stage += 1
		_world_lurches()
	if stage >= STAGE_MAX:
		_pending = 0


func _world_lurches() -> void:
	_apply_night_scaling()
	DreadManager.add_dread(STAGE_DREAD_HIT, &"hollowing")
	Sfx.play(&"bell_toll", -2.0, 0.01)  # distant village bells — read the world
	Sfx.play(&"whimper", -8.0)  # Briar feels it first (early-warning system)
	stage_advanced.emit(stage)
	if GameEvents:
		GameEvents.hollowing_stage_advanced.emit(stage)
		GameEvents.horror_stinger.emit(&"hollowing_stage")


## Night danger scales with stage (day-night-hideout.md interaction).
func _apply_night_scaling() -> void:
	DreadManager.register_zone_level(WorldState.NIGHT_DREAD_ZONE,
			WorldState.NIGHT_DREAD_LEVEL + NIGHT_FLOOR_PER_STAGE * stage)
	if WorldState.is_night() and GameEvents:
		GameEvents.dread_zone_entered.emit(WorldState.NIGHT_DREAD_ZONE)


func stage_name() -> StringName:
	return StringName(String(Stage.keys()[stage]).to_lower())


func get_save_data() -> Dictionary:
	return {
		"stage": stage,
		"alarm_points": alarm_points,
		"pending": _pending,
		"milestones": _milestones.duplicate(),
	}


func apply_save_data(data: Dictionary) -> void:
	stage = clampi(int(data.get("stage", 0)), 0, STAGE_MAX)
	alarm_points = float(data.get("alarm_points", 0.0))
	_pending = int(data.get("pending", 0))
	_milestones.assign(Array(data.get("milestones", [])).map(
		func(v: Variant) -> StringName: return StringName(v)))
	_apply_night_scaling()  # listeners re-read stage on their own _ready


func reset() -> void:
	stage = Stage.QUIET
	alarm_points = 0.0
	_pending = 0
	_dialogue_open = false
	_in_hideout = false
	_milestones.clear()
	_apply_night_scaling()
