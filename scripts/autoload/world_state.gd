extends Node
## Day/night world clock (docs/mechanics/day-night-hideout.md).
## Time advances by PLAYER ACTION, never wall-clock: story beats, hideout
## sleep, and (slice) the debug key. Night raises the dread floor via a
## pseudo dread-zone (+20, max-of-zones keeps deeper areas dominant).

signal time_changed(time_of_day: int, day: int)

enum TimeOfDay { DAWN, DAY, DUSK, NIGHT }

const NIGHT_DREAD_ZONE := &"night_floor"
const NIGHT_DREAD_LEVEL := 20.0

## Zone palette per time of day (CanvasModulate targets).
const PALETTES := {
	TimeOfDay.DAWN: Color(0.62, 0.52, 0.56),
	TimeOfDay.DAY: Color(0.8, 0.77, 0.72),
	TimeOfDay.DUSK: Color(0.38, 0.34, 0.44),
	TimeOfDay.NIGHT: Color(0.15, 0.15, 0.27),
}

## Significant actions + distance walked tick time forward (spec: time
## advances by player action). NIGHT never auto-advances — sleep or endure.
const ACTION_POINTS_PER_PHASE := 4.0
const WALK_PIXELS_PER_POINT := 1100.0

var time_of_day: TimeOfDay = TimeOfDay.DUSK  # the story begins the evening of the escape
var day: int = 1
var _action_points: float = 0.0
var _last_player_pos := Vector2.INF


func _ready() -> void:
	DreadManager.register_zone_level(NIGHT_DREAD_ZONE, NIGHT_DREAD_LEVEL)
	if GameEvents:
		GameEvents.diggable_revealed.connect(func(_id: StringName) -> void: register_action(2.0))
		GameEvents.monster_stilled.connect(func(_id: StringName) -> void: register_action(2.0))
		GameEvents.monster_dominated.connect(func(_id: StringName) -> void: register_action(2.0))
		GameEvents.enemy_died.connect(func(_kind: StringName) -> void: register_action(2.0))
		GameEvents.cutscene_finished.connect(func(_id: StringName) -> void: register_action(1.0))


func _physics_process(_delta: float) -> void:
	# distance walked counts as living through the day
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	if _last_player_pos == Vector2.INF:
		_last_player_pos = player.global_position
		return
	var moved := player.global_position.distance_to(_last_player_pos)
	_last_player_pos = player.global_position
	if moved < 200.0:  # ignore teleports (respawn, load)
		register_action(moved / WALK_PIXELS_PER_POINT)


func register_action(points: float) -> void:
	if time_of_day == TimeOfDay.NIGHT:
		return  # the night does not pass on its own — sleep or endure it
	_action_points += points
	if _action_points >= ACTION_POINTS_PER_PHASE:
		_action_points = 0.0
		advance_time()


func advance_time() -> void:
	_action_points = 0.0
	if time_of_day == TimeOfDay.NIGHT:
		time_of_day = TimeOfDay.DAWN
		day += 1
	else:
		time_of_day = (time_of_day + 1) as TimeOfDay
	_apply_night_floor()
	time_changed.emit(time_of_day, day)


## Hideout sleep: always wakes at dawn (next day if it wasn't already dawn).
func sleep_to_dawn() -> void:
	if time_of_day != TimeOfDay.DAWN:
		day += 1
	time_of_day = TimeOfDay.DAWN
	_apply_night_floor()
	time_changed.emit(time_of_day, day)


func is_night() -> bool:
	return time_of_day == TimeOfDay.NIGHT


func palette() -> Color:
	return PALETTES[time_of_day]


func get_save_data() -> Dictionary:
	return {"time_of_day": time_of_day, "day": day}


func apply_save_data(data: Dictionary) -> void:
	time_of_day = int(data.get("time_of_day", TimeOfDay.DUSK)) as TimeOfDay
	day = int(data.get("day", 1))
	_apply_night_floor()
	time_changed.emit(time_of_day, day)


func reset() -> void:
	time_of_day = TimeOfDay.DUSK
	day = 1
	_action_points = 0.0
	_last_player_pos = Vector2.INF
	_apply_night_floor()


func _apply_night_floor() -> void:
	if GameEvents:
		if is_night():
			GameEvents.dread_zone_entered.emit(NIGHT_DREAD_ZONE)
		else:
			GameEvents.dread_zone_exited.emit(NIGHT_DREAD_ZONE)
