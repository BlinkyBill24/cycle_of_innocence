class_name HollowHouseQuest
extends Node
## Orchestrates the Hollow House micro-quest (docs/design/hollow-house-quest.md)
## from EXISTING systems — no new autoloads. Knowledge-gated, not item-gated:
## the recontextualization beat fires only once the player has BOTH found the
## ledger AND witnessed enough doom-signals, in either order, so nothing is
## missable and the truth reframes what they already saw.
##
## Decoupled via GameEvents; reads no other script's vars by type.

## DiggableSpot holding the ledger (the hidden truth). Briar-seek leads here;
## the no-missable fallback lets Rowan dig it by hand.
@export var book_spot_path: NodePath
## Journal-id prefix the house's doom-signals share (WhisperSpot writes
## "sign_<spot_id>") — count only THIS house's signals toward the gate.
@export var doom_prefix: String = "sign_hollow"
## How many house doom-signals must be witnessed before the ledger means anything.
@export var doom_threshold: int = 2
## Revelation unlocked by the truth — drives ZoneManager recontext (group
## recontext_<id> / recontext_not_<id>) and the ledger's NG+ recontext lore.
@export var revelation_id: StringName = &"hollow_house_truth"
@export_file("*.dialogue") var dialogue_path: String = "res://resources/dialogue/hollow_house_book.dialogue"
const BALLOON_SCENE := "res://scenes/ui/dialogue_balloon.tscn"

var _book_spot: DiggableSpot
var _book_found := false
var _completed := false


func _ready() -> void:
	_book_spot = get_node_or_null(book_spot_path) as DiggableSpot
	GameEvents.diggable_revealed.connect(_on_diggable_revealed)
	GameEvents.journal_entry_added.connect(_on_journal_entry_added)
	GameEvents.companion_recalled.connect(_on_recalled)
	# a save loaded mid-quest may already satisfy the gate
	_maybe_complete.call_deferred()


# --- knowledge gate (pure, testable) ---

## True when at least `threshold` witnessed DOOM entries share `prefix`.
static func knowledge_gate_met(doom_entries: Array, prefix: String, threshold: int) -> bool:
	var n := 0
	for e: Dictionary in doom_entries:
		if String(e.get("id", "")).begins_with(prefix):
			n += 1
	return n >= threshold


func _gate_met() -> bool:
	return knowledge_gate_met(Journal.entries_of_kind(Journal.Kind.DOOM), doom_prefix, doom_threshold)


# --- signal handlers ---

func _on_diggable_revealed(spot_id: StringName) -> void:
	if _book_spot and spot_id == _book_spot.spot_id:
		_book_found = true
		_maybe_complete()


func _on_journal_entry_added(_sign_id: StringName) -> void:
	_maybe_complete()


## Player asked Briar to (re-)point at the ledger. Player-triggered, never auto —
## avoids the auto-interrupt annoyance (docs/mechanics/companion-pointer.md).
func _on_recalled() -> void:
	if _book_spot == null or _book_spot.revealed:
		return
	var briar := get_tree().get_first_node_in_group("companion") as CompanionBase
	if briar:
		briar.command_seek(_book_spot)


# --- the recontextualization beat ---

func _maybe_complete() -> void:
	if _completed or not _book_found or not _gate_met():
		return
	_completed = true
	# the truth reframes the space: recontext nodes swap (revelation_unlocked),
	# a single stinger, a dread spike, a witnessed DOOM entry, one balloon.
	PlayerData.unlock_revelation(revelation_id)
	GameEvents.horror_stinger.emit(&"hollow_house_truth")  # AdaptiveAudio ducks
	Sfx.play(&"stinger_toy", 0.0)
	DreadManager.add_dread(35.0, &"hollow_house_truth")
	Journal.witness(
		&"hollow_house_revealed",
		"The ledger is a lottery list. This house kept the numbers — and every name in the margin is a child's.",
		Journal.Kind.DOOM,
	)
	_play_balloon()


func _play_balloon() -> void:
	if dialogue_path.is_empty() or not ResourceLoader.exists(dialogue_path):
		return
	GameEvents.exploration_paused.emit()
	DialogueManager.show_dialogue_balloon_scene(BALLOON_SCENE, load(dialogue_path), "start")
	await DialogueManager.dialogue_ended
	GameEvents.exploration_resumed.emit()
