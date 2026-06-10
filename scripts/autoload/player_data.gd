extends Node
## Persistent run data for Cycle of Innocence.
## Age, morality, animal bonds/corruption, revelations, appearance flags, save position.
## Single source of truth per progression.md — visuals and Yarn listen via signals.

signal age_advanced(new_stage: int)
signal morality_changed(new_value: float, delta: float)
signal bond_changed(companion_id: StringName, new_value: float)
signal corruption_changed(companion_id: StringName, new_value: float)
signal revelation_unlocked(revelation_id: StringName)

enum AgeStage { CHILD = 0, TEEN = 1, ADULT = 2 }

## Morality tiers per docs/mechanics/progression.md
enum MoralityTier { INNOCENT_EMPATH = 0, WOUNDED = 1, HARDENED = 2, VESSEL = 3 }

const MORALITY_MIN := -100.0
const MORALITY_MAX := 100.0
const BOND_MIN := 0.0
const BOND_MAX := 100.0
const CORRUPTION_MIN := 0.0
const CORRUPTION_MAX := 100.0

const TIER_INNOCENT_MAX := -40.0
const TIER_WOUNDED_MAX := 39.0
const TIER_HARDENED_MAX := 80.0

const BRIAR_ID := &"briar"
const ECHO_ID := &"echo"
const STORM_ID := &"storm"

var age_stage: AgeStage = AgeStage.CHILD
var morality: float = 0.0  # -100 (innocent/kind) ... +100 (ruthless/vessel)

# Companions: id -> {bond: float, corruption: float, growth: float, alive: bool}
var companions: Dictionary = {}

var known_revelations: Array[StringName] = []
var appearance_flags: Array[StringName] = []  # e.g. "ritual_scar", "marked", "hardened"

var custom_name: String = "Rowan"
var gender: String = "neutral"
var chosen_accent_color: Color = Color(0.55, 0.45, 0.35, 1.0)

var max_hp: int = 20
var current_hp: int = 20

var last_zone_id: StringName = &"playground_fringes"
var spawn_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	if companions.is_empty():
		_init_slice_companions()


func reset_to_defaults() -> void:
	age_stage = AgeStage.CHILD
	morality = 0.0
	companions.clear()
	known_revelations.clear()
	appearance_flags.clear()
	custom_name = "Rowan"
	gender = "neutral"
	chosen_accent_color = Color(0.55, 0.45, 0.35, 1.0)
	max_hp = 20
	current_hp = max_hp
	last_zone_id = &"playground_fringes"
	spawn_position = Vector2.ZERO
	_init_slice_companions()


func get_morality_tier() -> MoralityTier:
	if morality <= TIER_INNOCENT_MAX:
		return MoralityTier.INNOCENT_EMPATH
	if morality <= TIER_WOUNDED_MAX:
		return MoralityTier.WOUNDED
	if morality <= TIER_HARDENED_MAX:
		return MoralityTier.HARDENED
	return MoralityTier.VESSEL


func get_morality_tier_name() -> StringName:
	match get_morality_tier():
		MoralityTier.INNOCENT_EMPATH:
			return &"innocent_empath"
		MoralityTier.WOUNDED:
			return &"wounded"
		MoralityTier.HARDENED:
			return &"hardened"
		MoralityTier.VESSEL:
			return &"vessel"
	return &"wounded"


func get_companion(id: StringName) -> Dictionary:
	_ensure_companion(id)
	return companions[id]


func set_age_stage(stage: AgeStage) -> void:
	if stage < AgeStage.CHILD or stage > AgeStage.ADULT:
		push_warning("PlayerData.set_age_stage: invalid stage %d" % stage)
		return
	if age_stage == stage:
		return
	age_stage = stage
	age_advanced.emit(age_stage)
	if GameEvents:
		GameEvents.age_advanced.emit(age_stage)


func change_morality(delta: float) -> void:
	var previous := morality
	morality = clampf(morality + delta, MORALITY_MIN, MORALITY_MAX)
	var actual_delta := morality - previous
	if is_zero_approx(actual_delta):
		return
	_sync_morality_appearance_flags()
	morality_changed.emit(morality, actual_delta)
	if GameEvents:
		GameEvents.morality_changed.emit(morality, actual_delta)


func unlock_revelation(id: StringName) -> void:
	if id.is_empty():
		push_warning("PlayerData.unlock_revelation: empty id")
		return
	if id in known_revelations:
		return
	known_revelations.append(id)
	revelation_unlocked.emit(id)
	if GameEvents:
		GameEvents.revelation_unlocked.emit(id)


func set_companion_bond(id: StringName, value: float) -> void:
	if not _is_known_companion_id(id):
		push_warning("PlayerData.set_companion_bond: unexpected companion '%s' (slice expects briar/echo/storm)" % id)
	_ensure_companion(id)
	var previous: float = companions[id].bond
	var clamped := clampf(value, BOND_MIN, BOND_MAX)
	companions[id].bond = clamped
	if is_equal_approx(previous, clamped):
		return
	bond_changed.emit(id, clamped)
	if GameEvents:
		GameEvents.companion_bond_changed.emit(id, clamped)


func set_companion_corruption(id: StringName, value: float) -> void:
	if not _is_known_companion_id(id):
		push_warning("PlayerData.set_companion_corruption: unexpected companion '%s'" % id)
	_ensure_companion(id)
	var previous: float = companions[id].corruption
	var clamped := clampf(value, CORRUPTION_MIN, CORRUPTION_MAX)
	companions[id].corruption = clamped
	if is_equal_approx(previous, clamped):
		return
	corruption_changed.emit(id, clamped)
	if GameEvents:
		GameEvents.companion_corrupted.emit(id, clamped)


func set_companion_growth(id: StringName, value: float) -> void:
	_ensure_companion(id)
	companions[id].growth = clampf(value, 0.0, 100.0)


func set_companion_alive(id: StringName, alive: bool) -> void:
	_ensure_companion(id)
	companions[id].alive = alive


func add_appearance_flag(flag: StringName) -> void:
	if flag not in appearance_flags:
		appearance_flags.append(flag)


func is_revelation_known(id: StringName) -> bool:
	return id in known_revelations


func _init_slice_companions() -> void:
	# Act 0 escape: Briar pup bonds with Rowan in playground fringes (story bible).
	_ensure_companion(BRIAR_ID)
	companions[BRIAR_ID].bond = 25.0
	companions[BRIAR_ID].corruption = 0.0
	companions[BRIAR_ID].growth = 0.0
	companions[BRIAR_ID].alive = true
	# Echo / Storm stubs — not active in vertical slice.
	_ensure_companion(ECHO_ID)
	_ensure_companion(STORM_ID)


func _ensure_companion(id: StringName) -> void:
	if companions.has(id):
		return
	companions[id] = {
		"bond": 0.0,
		"corruption": 0.0,
		"growth": 0.0,
		"alive": true,
	}


func _is_known_companion_id(id: StringName) -> bool:
	return id == BRIAR_ID or id == ECHO_ID or id == STORM_ID


func _sync_morality_appearance_flags() -> void:
	var tier := get_morality_tier()
	_remove_appearance_flag(&"innocent_glow")
	_remove_appearance_flag(&"hardened")
	_remove_appearance_flag(&"marked")
	match tier:
		MoralityTier.INNOCENT_EMPATH:
			add_appearance_flag(&"innocent_glow")
		MoralityTier.HARDENED:
			add_appearance_flag(&"hardened")
			add_appearance_flag(&"marked")
		MoralityTier.VESSEL:
			add_appearance_flag(&"marked")


func _remove_appearance_flag(flag: StringName) -> void:
	var idx := appearance_flags.find(flag)
	if idx >= 0:
		appearance_flags.remove_at(idx)
