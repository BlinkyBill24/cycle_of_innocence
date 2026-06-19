class_name HollowHouseQuest
extends Node
## Orchestrates the Hollow House micro-quest (docs/design/hollow-house-quest.md)
## from EXISTING systems — no new autoloads. Hybrid gate (2026-06-19 pivot, see
## docs/decisions/2026-06-19-hollow-house-key-gate-hybrid.md): a buried KEY gates
## the back nook, but the recontextualization beat stays KNOWLEDGE-gated — it
## fires only once the player has BOTH read the ledger (in the nook) AND
## witnessed enough doom-signals, in either order, so the truth reframes what
## they already saw and nothing is missable.
##
## The book lives in a separate nook scene, so this node is the hall-side
## safety-net: it re-checks the gate whenever a new sign is witnessed (the book
## itself fires try_fire on read; this catches the read-book-then-see-more case).
## Decoupled via GameEvents; reads no other script's vars by type.

## DiggableSpot Briar leads to on recall (the buried key — the current obstacle).
## The no-missable fallback lets Rowan dig it by hand if Briar refuses.
@export var seek_spot_path: NodePath
## Journal-id prefix the house's doom-signals share (WhisperSpot writes
## "sign_<spot_id>") — count only THIS house's signals toward the gate.
@export var doom_prefix: String = "sign_hollow"
## How many house doom-signals must be witnessed before the ledger means anything.
@export var doom_threshold: int = 2
## Revelation unlocked by the truth — drives ZoneManager recontext (group
## recontext_<id> / recontext_not_<id>) and the ledger's NG+ recontext lore.
@export var revelation_id: StringName = &"hollow_house_truth"
## Persistent flag the nook's book sets when read (SearchableClue.book_read_flag).
@export var book_read_flag: StringName = &"hollow_book_read"

var _seek_spot: DiggableSpot


func _ready() -> void:
	_seek_spot = get_node_or_null(seek_spot_path) as DiggableSpot
	GameEvents.journal_entry_added.connect(_on_journal_entry_added)
	GameEvents.companion_recalled.connect(_on_recalled)
	# returning to the hall after reading the book — or a save loaded mid-quest —
	# may already satisfy the gate; re-check once the scene is up.
	_maybe_fire.call_deferred()


# --- knowledge gate (pure, testable) ---

## True when at least `threshold` witnessed DOOM entries share `prefix`.
static func knowledge_gate_met(doom_entries: Array, prefix: String, threshold: int) -> bool:
	var n := 0
	for e: Dictionary in doom_entries:
		if String(e.get("id", "")).begins_with(prefix):
			n += 1
	return n >= threshold


## The recontextualization beat, fired from EITHER the nook book (on read) or the
## hall safety-net (on a later sign) — whichever completes the gate last. Reads
## only autoloads, so it is callable statically across scenes. Idempotent: the
## revelation guard makes a second call a no-op. Returns true only when it fires.
static func try_fire(
	rev_id: StringName, prefix: String, threshold: int, read_flag: StringName
) -> bool:
	if PlayerData.is_revelation_known(rev_id):
		return false
	if not PlayerData.has_story_flag(read_flag):
		return false
	if not knowledge_gate_met(Journal.entries_of_kind(Journal.Kind.DOOM), prefix, threshold):
		return false
	# the truth reframes the space: recontext nodes swap on the next zone enter,
	# a single stinger, a dread spike, a witnessed DOOM entry.
	PlayerData.unlock_revelation(rev_id)
	GameEvents.horror_stinger.emit(&"hollow_house_truth")  # AdaptiveAudio ducks
	Sfx.play(&"stinger_toy", 0.0)
	DreadManager.add_dread(35.0, &"hollow_house_truth")
	Journal.witness(
		&"hollow_house_revealed",
		"The ledger is a lottery list. This house kept the numbers — and every name in the margin is a child's.",
		Journal.Kind.DOOM,
	)
	return true


# --- signal handlers ---

func _on_journal_entry_added(_sign_id: StringName) -> void:
	_maybe_fire()


func _maybe_fire() -> void:
	try_fire(revelation_id, doom_prefix, doom_threshold, book_read_flag)


## Player asked Briar to (re-)point at the buried key. Player-triggered, never
## auto — avoids the auto-interrupt annoyance (docs/mechanics/companion-pointer.md).
func _on_recalled() -> void:
	if _seek_spot == null or _seek_spot.revealed:
		return
	var briar := get_tree().get_first_node_in_group("companion") as CompanionBase
	if briar:
		briar.command_seek(_seek_spot)
