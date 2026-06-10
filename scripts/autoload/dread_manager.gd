extends Node
## Global dread system per docs/mechanics/horror-and-dread.md.
## Dread (0-100) creeps toward a zone baseline, spikes on events, and exposes
## mechanical multipliers + a presentation strength for shaders/audio.
## Horror intensity scales PRESENTATION ONLY — mechanics are never softened.

signal dread_changed(value: float, delta: float)
signal dread_tier_changed(new_tier: int)

enum DreadTier { CALM = 0, UNEASY = 1, FEARFUL = 2, TERROR = 3 }

const DREAD_MIN := 0.0
const DREAD_MAX := 100.0

const TIER_CALM_MAX := 25.0
const TIER_UNEASY_MAX := 60.0
const TIER_FEARFUL_MAX := 85.0

const RISE_PER_SECOND := 4.0
const DECAY_PER_SECOND := 2.0
const DEFAULT_ZONE_BASELINE := 40.0
const REVELATION_DREAD := 15.0
const COMPANION_CORRUPTION_DREAD := 10.0
const COMPANION_CORRUPTION_THRESHOLD := 70.0

var dread: float = 0.0
var horror_intensity: float = 1.0

# zone_id -> baseline level; effective baseline is the max of active zones (0 if none).
var _active_zones: Dictionary = {}
var _registered_zone_levels: Dictionary = {}
var _last_tier: DreadTier = DreadTier.CALM


func _ready() -> void:
	if GameEvents:
		GameEvents.dread_zone_entered.connect(_on_dread_zone_entered)
		GameEvents.dread_zone_exited.connect(_on_dread_zone_exited)
		GameEvents.revelation_unlocked.connect(_on_revelation_unlocked)
		GameEvents.companion_corrupted.connect(_on_companion_corrupted)


func _process(delta: float) -> void:
	var baseline := get_zone_baseline()
	if is_equal_approx(dread, baseline):
		return
	if dread < baseline:
		_set_dread(minf(dread + RISE_PER_SECOND * delta, baseline))
	else:
		_set_dread(maxf(dread - DECAY_PER_SECOND * delta, baseline))


func add_dread(amount: float, _source: StringName = &"") -> void:
	_set_dread(dread + amount)


func reduce_dread(amount: float) -> void:
	add_dread(-absf(amount))


## Zones with bespoke dread levels register once (e.g. from zone scene _ready).
func register_zone_level(zone_id: StringName, baseline: float) -> void:
	_registered_zone_levels[zone_id] = clampf(baseline, DREAD_MIN, DREAD_MAX)


func get_zone_baseline() -> float:
	var baseline := 0.0
	for level: float in _active_zones.values():
		baseline = maxf(baseline, level)
	return baseline


func get_tier() -> DreadTier:
	if dread <= TIER_CALM_MAX:
		return DreadTier.CALM
	if dread <= TIER_UNEASY_MAX:
		return DreadTier.UNEASY
	if dread <= TIER_FEARFUL_MAX:
		return DreadTier.FEARFUL
	return DreadTier.TERROR


func get_tier_name() -> StringName:
	match get_tier():
		DreadTier.CALM:
			return &"calm"
		DreadTier.UNEASY:
			return &"uneasy"
		DreadTier.FEARFUL:
			return &"fearful"
		DreadTier.TERROR:
			return &"terror"
	return &"calm"


## Mechanics hooks — NOT scaled by horror_intensity.
func get_stamina_regen_multiplier() -> float:
	return lerpf(1.0, 0.5, dread / DREAD_MAX)


func get_companion_reliability() -> float:
	return lerpf(1.0, 0.6, dread / DREAD_MAX)


## Presentation strength for shaders/audio — the ONLY value horror_intensity scales.
func get_presentation_strength() -> float:
	return (dread / DREAD_MAX) * horror_intensity


func set_horror_intensity(value: float) -> void:
	horror_intensity = clampf(value, 0.0, 1.0)


func reset() -> void:
	_active_zones.clear()
	var previous := dread
	dread = 0.0
	_last_tier = DreadTier.CALM
	if not is_equal_approx(previous, 0.0):
		dread_changed.emit(dread, -previous)


func _set_dread(value: float) -> void:
	var clamped := clampf(value, DREAD_MIN, DREAD_MAX)
	if is_equal_approx(clamped, dread):
		return
	var delta := clamped - dread
	dread = clamped
	dread_changed.emit(dread, delta)
	var tier := get_tier()
	if tier != _last_tier:
		_last_tier = tier
		dread_tier_changed.emit(tier)


func _on_dread_zone_entered(zone_id: StringName) -> void:
	var level: float = _registered_zone_levels.get(zone_id, DEFAULT_ZONE_BASELINE)
	_active_zones[zone_id] = level


func _on_dread_zone_exited(zone_id: StringName) -> void:
	_active_zones.erase(zone_id)


func _on_revelation_unlocked(_revelation_id: StringName) -> void:
	add_dread(REVELATION_DREAD, &"revelation")


func _on_companion_corrupted(_companion_id: StringName, level: float) -> void:
	if level >= COMPANION_CORRUPTION_THRESHOLD:
		add_dread(COMPANION_CORRUPTION_DREAD, &"companion_corruption")
