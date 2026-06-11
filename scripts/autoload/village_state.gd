extends Node
## Village life (docs/mechanics/village-life.md): authored NPC routines,
## per-NPC suspicion that feeds the Hollowing clock, and stage-keyed gossip.
## All villagers are AUTHORED — names matter because their children have
## names. Schedules are plain data; no off-screen simulation.

signal suspicion_changed(npc_id: StringName, value: float)
signal villager_reported(npc_id: StringName)

const SUSPICION_MAX := 100.0
const SUSPICION_REPORT_THRESHOLD := 100.0
const REPORT_ALARM_POINTS := 25.0  # a quarter-stage per villager who talks
const SUSPICION_DECAY_PER_PHASE := 0.7  # time quiets rumors

## Authored routines: npc_id -> TimeOfDay -> {marker, activity}.
## Markers are resolved per-zone via node groups "marker_<name>".
## Hollowing shifts (resolve_slot): stage >= 2 hardens routines; stage 3
## stops some entirely — the empty bench at the usual hour says it.
const SCHEDULES := {
	&"marta_farmer": {
		WorldState.TimeOfDay.DAWN: {"marker": &"field_west", "activity": &"work"},
		WorldState.TimeOfDay.DAY: {"marker": &"field_west", "activity": &"work"},
		WorldState.TimeOfDay.DUSK: {"marker": &"green_bench", "activity": &"social"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"house_marta", "activity": &"home"},
	},
	&"pieter_parent": {
		WorldState.TimeOfDay.DAWN: {"marker": &"well", "activity": &"chores"},
		WorldState.TimeOfDay.DAY: {"marker": &"market", "activity": &"work"},
		WorldState.TimeOfDay.DUSK: {"marker": &"green_bench", "activity": &"social"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"house_pieter", "activity": &"home"},
	},
	&"elder_aldwin": {
		WorldState.TimeOfDay.DAWN: {"marker": &"chapel", "activity": &"rite"},
		WorldState.TimeOfDay.DAY: {"marker": &"green_center", "activity": &"blessing"},
		WorldState.TimeOfDay.DUSK: {"marker": &"chapel", "activity": &"rite"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"chapel", "activity": &"vigil"},
	},
	&"warden_brek": {
		WorldState.TimeOfDay.DAWN: {"marker": &"gate_east", "activity": &"watch"},
		WorldState.TimeOfDay.DAY: {"marker": &"green_center", "activity": &"watch"},
		WorldState.TimeOfDay.DUSK: {"marker": &"gate_east", "activity": &"patrol"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"lane_north", "activity": &"patrol"},
	},
	&"lena_child": {
		WorldState.TimeOfDay.DAWN: {"marker": &"house_marta", "activity": &"home"},
		WorldState.TimeOfDay.DAY: {"marker": &"green_center", "activity": &"play"},
		WorldState.TimeOfDay.DUSK: {"marker": &"green_bench", "activity": &"play"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"house_marta", "activity": &"home"},
	},
	# Stage-2 search detail: a second warden sweeps the playground — the
	# village comes looking (his markers live in playground_fringes).
	&"warden_oslo": {
		WorldState.TimeOfDay.DAWN: {"marker": &"search_gate", "activity": &"search"},
		WorldState.TimeOfDay.DAY: {"marker": &"search_plaza", "activity": &"search"},
		WorldState.TimeOfDay.DUSK: {"marker": &"search_path", "activity": &"search"},
		WorldState.TimeOfDay.NIGHT: {"marker": &"search_plaza", "activity": &"search"},
	},
}

## These routines only BEGIN at stage >= 2 (the inverse of stopping):
## the search detail exists because the village started to fear.
const STAGE2_STARTED: Array[StringName] = [&"warden_oslo"]

## Stage >= 2: children stop playing outside, parents harden their routine.
const STAGE2_OVERRIDES := {
	&"lena_child": {
		WorldState.TimeOfDay.DAY: {"marker": &"house_marta", "activity": &"home"},
		WorldState.TimeOfDay.DUSK: {"marker": &"house_marta", "activity": &"home"},
	},
	&"pieter_parent": {
		WorldState.TimeOfDay.DUSK: {"marker": &"house_pieter", "activity": &"home"},
	},
}

## Stage 3: these schedules simply STOP (their child was taken).
const STAGE3_STOPPED: Array[StringName] = [&"marta_farmer", &"lena_child"]

## Gossip pools per hollowing stage. `intel: true` lines carry real
## information (a name, a route, a date) — the systemic lore channel.
const GOSSIP := {
	0: [
		{"text": "Thank the Lottery it wasn't ours this year...", "intel": false},
		{"text": "The Harmony Score posts again come spring. Keep tithing.", "intel": false},
		{"text": "Father Aldwin says the playground stays closed till the paint dries. Odd — nobody painted.", "intel": true},
	],
	1: [
		{"text": "The dogs won't go past the east fence anymore.", "intel": false},
		{"text": "Brek walks the north lane twice a night now. Twice!", "intel": true},
		{"text": "Someone's been at the bread. Mice, surely. Surely mice.", "intel": false},
	],
	2: [
		{"text": "Keep the children in after dusk. Warden's orders.", "intel": false},
		{"text": "They're saying the offering didn't take. That it's OUT there.", "intel": true},
		{"text": "Old Marta hasn't opened her shutters in two days.", "intel": true},
	],
	3: [
		{"text": "The chapel bell rang at midnight. Nobody rang it.", "intel": false},
		{"text": "Aldwin's calling an emergency lottery. The numbers are already stitched.", "intel": true},
		{"text": "I saw something small moving by the fences. Small like a child.", "intel": false},
	],
}

var suspicion: Dictionary = {}
var _reported: Array[StringName] = []
var _gossip_cursor: int = 0


func _ready() -> void:
	WorldState.time_changed.connect(_on_time_changed)


## Pure rule, unit-tested: where an NPC is in a given slot, after hollowing
## shifts. Empty dictionary = the routine has stopped.
static func resolve_slot(npc_id: StringName, time_of_day: int, stage: int) -> Dictionary:
	if stage < 2 and npc_id in STAGE2_STARTED:
		return {}
	if stage >= 3 and npc_id in STAGE3_STOPPED:
		return {}
	if stage >= 2 and STAGE2_OVERRIDES.has(npc_id):
		var overrides: Dictionary = STAGE2_OVERRIDES[npc_id]
		if overrides.has(time_of_day):
			return overrides[time_of_day]
	var schedule: Dictionary = SCHEDULES.get(npc_id, {})
	return schedule.get(time_of_day, {})


## Sightings raise suspicion; crossing the threshold converts to hollowing
## alarm ONCE per villager — the clock advances because specific people
## started talking.
func add_suspicion(npc_id: StringName, amount: float) -> void:
	var value: float = clampf(float(suspicion.get(npc_id, 0.0)) + amount, 0.0, SUSPICION_MAX)
	suspicion[npc_id] = value
	suspicion_changed.emit(npc_id, value)
	if value >= SUSPICION_REPORT_THRESHOLD and npc_id not in _reported:
		_reported.append(npc_id)
		HollowingClock.add_alarm(REPORT_ALARM_POINTS)
		villager_reported.emit(npc_id)


func get_suspicion(npc_id: StringName) -> float:
	return float(suspicion.get(npc_id, 0.0))


func has_reported(npc_id: StringName) -> bool:
	return npc_id in _reported


## High-suspicion villagers change their own gossip — the net closing.
func pick_gossip(stage: int, suspicious: bool = false) -> String:
	if suspicious:
		return "I saw something small moving by the fences... I'm sure of it."
	var pool: Array = GOSSIP.get(clampi(stage, 0, 3), [])
	if pool.is_empty():
		return ""
	_gossip_cursor += 1
	return pool[_gossip_cursor % pool.size()]["text"]


func _on_time_changed(_time: int, _day: int) -> void:
	for npc_id: StringName in suspicion:
		suspicion[npc_id] = float(suspicion[npc_id]) * SUSPICION_DECAY_PER_PHASE


func get_save_data() -> Dictionary:
	return {
		"suspicion": suspicion.duplicate(),
		"reported": _reported.duplicate(),
	}


func apply_save_data(data: Dictionary) -> void:
	suspicion = {}
	var saved: Dictionary = data.get("suspicion", {})
	for id: Variant in saved:
		suspicion[StringName(id)] = float(saved[id])
	_reported.assign(Array(data.get("reported", [])).map(
		func(v: Variant) -> StringName: return StringName(v)))


func reset() -> void:
	suspicion.clear()
	_reported.clear()
	_gossip_cursor = 0
