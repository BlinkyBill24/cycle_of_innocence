class_name NpcThrowReaction
extends Area2D
## A SHOWCASE reaction: when a thrown object (shared thrown-hit path, group "thrown")
## strikes this one authored NPC, they react with a scripted, HAND-AUTHORED line
## chosen by their CURRENT state — and a small body-language flinch.
##
## HARD GUARDRAIL (village-life / patent posture): this is a fixed table keyed to
## the NPC's identity + current state ONLY. It does NOT learn, remember across
## encounters, build a grudge, or pursue — no procedural/"nemesis" behavior. The
## reaction LINE branches on HollowingClock.stage + VillageState suspicion (the
## net closing), never on how many times you've thrown at them. One NPC, by design;
## every other villager ignores thrown objects.

## The authored line variants live in a Dialogue Manager .dialogue (titles
## calm/wary/afraid), read at runtime and shown as a diegetic floating balloon
## (not the modal conversation UI — keeps the bark non-blocking + "no UI popup").
const REACTION_PATH := "res://resources/dialogue/marta_throw_reaction.dialogue"

@export var npc_id: StringName = &"marta_farmer"
## A provocation IS noticed — being struck raises the village's suspicion of Rowan.
@export var provoke_suspicion: float = 25.0
## Hurting a person hardens you a little (toward Vessel).
@export var provoke_morality: float = 4.0
## State thresholds for the line choice (current suspicion, 0..100).
const WARY_SUSPICION := 30.0
const AFRAID_SUSPICION := 70.0
const REFIRE_COOLDOWN := 0.8  # one rock = one reaction (debounce, NOT memory)

var _cooldown := 0.0
var _balloon: Label


func _ready() -> void:
	monitoring = true
	collision_mask = 32  # the hit_hurt layer, where thrown Hitboxes live
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func _on_area_entered(area: Area2D) -> void:
	# only THROWN objects provoke — a melee swing nearby must not (it isn't "thrown")
	if _cooldown > 0.0 or not area.is_in_group("thrown"):
		return
	_cooldown = REFIRE_COOLDOWN
	react()


## Fire the scripted reaction for the NPC's CURRENT state. Public so tests can
## invoke it directly.
func react() -> void:
	var title := choose_reaction_title(HollowingClock.stage, VillageState.get_suspicion(npc_id))
	_provoke(title)
	_speak(title)


## Pure rule (unit-tested): which authored line fits the NPC's state RIGHT NOW —
## calm early, wary as the stage/suspicion climb, afraid once the net is closing.
## A function of current state only; no history, no escalation-by-repetition.
static func choose_reaction_title(stage: int, suspicion: float) -> StringName:
	if stage >= 2 or suspicion >= AFRAID_SUSPICION:
		return &"afraid"
	if stage >= 1 or suspicion >= WARY_SUSPICION:
		return &"wary"
	return &"calm"


## The consequences of the provocation (no presentation): the village notices, it
## hardens Rowan a touch, and the bus is told. Persisted via VillageState/PlayerData.
func _provoke(title: StringName) -> void:
	VillageState.add_suspicion(npc_id, provoke_suspicion)
	PlayerData.change_morality(provoke_morality)
	_flinch()
	if GameEvents:
		GameEvents.npc_reacted_to_throw.emit(npc_id, title)


## Body language: a brief recoil flash on the NPC sprite (the parent).
func _flinch() -> void:
	var npc := get_parent()
	if npc is CanvasItem:
		var tween := create_tween()
		tween.tween_property(npc, "modulate", Color(1.4, 0.85, 0.85), 0.08)
		tween.tween_property(npc, "modulate", Color.WHITE, 0.28)


## Presentation: float the authored line as a diegetic balloon. Skipped in headless
## test runs (agents are runtime-blind; the balloon is an F5 check).
func _speak(title: StringName) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var resource: DialogueResource = load(REACTION_PATH)
	if resource == null:
		return
	var line: DialogueLine = await DialogueManager.get_next_dialogue_line(resource, String(title))
	if line != null:
		_float_balloon(line.text)


func _float_balloon(text: String) -> void:
	if _balloon and is_instance_valid(_balloon):
		_balloon.queue_free()
	_balloon = Label.new()
	_balloon.text = text
	_balloon.add_theme_font_size_override("font_size", 10)
	_balloon.add_theme_color_override("font_color", Color(0.95, 0.92, 0.86))
	_balloon.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_balloon.add_theme_constant_override("outline_size", 3)
	_balloon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_balloon)
	_balloon.position = Vector2(-_balloon.size.x / 2.0, -40.0)
	_balloon.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_balloon, "modulate:a", 1.0, 0.25)
	tween.tween_interval(2.4)
	tween.tween_property(_balloon, "modulate:a", 0.0, 0.8)
	tween.tween_callback(_balloon.queue_free)
