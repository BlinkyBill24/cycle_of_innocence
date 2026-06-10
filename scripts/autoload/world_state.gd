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

var time_of_day: TimeOfDay = TimeOfDay.DUSK  # the story begins the evening of the escape
var day: int = 1


func _ready() -> void:
	DreadManager.register_zone_level(NIGHT_DREAD_ZONE, NIGHT_DREAD_LEVEL)


func advance_time() -> void:
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
	_apply_night_floor()


func _apply_night_floor() -> void:
	if GameEvents:
		if is_night():
			GameEvents.dread_zone_entered.emit(NIGHT_DREAD_ZONE)
		else:
			GameEvents.dread_zone_exited.emit(NIGHT_DREAD_ZONE)
