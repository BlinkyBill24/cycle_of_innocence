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
var story_flags: Array[StringName] = []  # choice-matrix flags, e.g. "food_shared"
var spared_count: int = 0  # encounters-mercy.md: choice-matrix/endings inputs
var dominated_count: int = 0

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
	story_flags.clear()
	spared_count = 0
	dominated_count = 0
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
	_check_quirk_acquisition(id, &"bond", clamped)


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
	_check_quirk_acquisition(id, &"corruption", clamped)


func get_companion_quirks(id: StringName) -> Array:
	var quirks: Array = get_companion(id).get("quirks", [])
	return quirks


func has_quirk(id: StringName, quirk_id: StringName) -> bool:
	return quirk_id in get_companion_quirks(id)


## Quirks are acquired at authored thresholds and never lost — hideout care
## softens how they express, not whether they exist (companion-quirks.md).
func _check_quirk_acquisition(id: StringName, stat: StringName, value: float) -> void:
	_ensure_companion(id)
	var owned: Array = companions[id].get("quirks", [])
	for quirk_id: StringName in CompanionQuirkDefs.newly_acquired(id, stat, value, owned):
		owned.append(quirk_id)
		companions[id]["quirks"] = owned
		if GameEvents:
			GameEvents.quirk_acquired.emit(id, quirk_id)


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


## Mercy bookkeeping (encounters-mercy.md): permanent history for the
## choice matrix — betrayal clears the stilled_ state flag, never these.
func record_spared(id: StringName) -> void:
	spared_count += 1
	set_story_flag(StringName("spared_" + String(id)))


func record_dominated(id: StringName) -> void:
	dominated_count += 1
	set_story_flag(StringName("dominated_" + String(id)))


func set_story_flag(flag: StringName) -> void:
	if not flag.is_empty() and flag not in story_flags:
		story_flags.append(flag)


func has_story_flag(flag: StringName) -> bool:
	return flag in story_flags


## Delta helpers — primary API for dialogue mutations (Dialogue Manager).
func add_companion_bond(id: StringName, delta: float) -> void:
	set_companion_bond(id, get_companion(id).bond + delta)


func add_companion_corruption(id: StringName, delta: float) -> void:
	set_companion_corruption(id, get_companion(id).corruption + delta)


## --- persistence (used by SaveManager) ---

func get_save_data() -> Dictionary:
	return {
		"age_stage": age_stage,
		"morality": morality,
		"companions": companions.duplicate(true),
		"known_revelations": known_revelations.duplicate(),
		"appearance_flags": appearance_flags.duplicate(),
		"story_flags": story_flags.duplicate(),
		"spared_count": spared_count,
		"dominated_count": dominated_count,
		"custom_name": custom_name,
		"gender": gender,
		"chosen_accent_color": chosen_accent_color.to_html(),
		"max_hp": max_hp,
		"current_hp": current_hp,
		"last_zone_id": last_zone_id,
		"spawn_position": [spawn_position.x, spawn_position.y],
	}


func apply_save_data(data: Dictionary) -> void:
	age_stage = int(data.get("age_stage", AgeStage.CHILD)) as AgeStage
	morality = float(data.get("morality", 0.0))
	companions = {}
	var saved_companions: Dictionary = data.get("companions", {})
	for id: Variant in saved_companions:
		companions[StringName(id)] = Dictionary(saved_companions[id]).duplicate()
	known_revelations.assign(Array(data.get("known_revelations", [])).map(
		func(v: Variant) -> StringName: return StringName(v)))
	appearance_flags.assign(Array(data.get("appearance_flags", [])).map(
		func(v: Variant) -> StringName: return StringName(v)))
	story_flags.assign(Array(data.get("story_flags", [])).map(
		func(v: Variant) -> StringName: return StringName(v)))
	spared_count = int(data.get("spared_count", 0))
	dominated_count = int(data.get("dominated_count", 0))
	custom_name = str(data.get("custom_name", "Rowan"))
	gender = str(data.get("gender", "neutral"))
	chosen_accent_color = Color.from_string(str(data.get("chosen_accent_color", "")), chosen_accent_color)
	max_hp = int(data.get("max_hp", 20))
	current_hp = int(data.get("current_hp", max_hp))
	last_zone_id = StringName(str(data.get("last_zone_id", &"playground_fringes")))
	var pos: Array = data.get("spawn_position", [0.0, 0.0])
	spawn_position = Vector2(float(pos[0]), float(pos[1]))
	if companions.is_empty():
		_init_slice_companions()
	# listeners (visuals, HUD) resync from signals
	age_advanced.emit(age_stage)
	morality_changed.emit(morality, 0.0)
	for id: StringName in companions:
		bond_changed.emit(id, companions[id].bond)
		corruption_changed.emit(id, companions[id].corruption)


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
		"quirks": [],
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
