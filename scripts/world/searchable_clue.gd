class_name SearchableClue
extends Area2D
## An INTERACT-able prop that yields a witnessed Journal entry the first time
## Rowan searches it (secrets-and-discovery.md). Mirrors DiggableSpot's lore
## write, but it is *searched* (press interact) rather than dug — for things no
## dog unearths: a book left open, a child's primer, a name scratched in tin.
##
## The load-bearing "book" sets `marks_book_read` so reading it fires the Hollow
## House recontextualization beat (HollowHouseQuest.try_fire) once the player has
## also witnessed enough doom-signals — knowledge-gated, in either order, so the
## truth reframes signs already seen (docs/design/hollow-house-quest.md).

@export var spot_id: StringName = &"unnamed_clue"
@export_multiline var lore_text: String = ""
## NG+/recontext read: chosen once `recontext_revelation` is known (DiggableSpot
## shares the same choose_lore rule — one object, read with knowledge).
@export_multiline var lore_text_recontext: String = ""
@export var recontext_revelation: StringName = &""
@export_enum("Lore", "Doom") var journal_kind: int = 0
@export var prompt_text := "Search"
## Optional Dialogue Manager balloon played on the first search (the book's voice).
@export_file("*.dialogue") var dialogue_path: String = ""

## The one load-bearing book: marks the quest's book-read flag and drives the
## recontextualization beat. Leave false for a plain lore clue prop.
@export var marks_book_read := false
@export var book_read_flag: StringName = &"hollow_book_read"
@export var revelation_id: StringName = &"hollow_house_truth"
@export var doom_prefix: String = "sign_hollow"
@export var doom_threshold: int = 2

const BALLOON_SCENE := "res://scenes/ui/dialogue_balloon.tscn"

var searched := false
var _player_inside := false
var _label: Label
var _label_layer: CanvasLayer


func _ready() -> void:
	add_to_group("searchable")
	monitoring = true
	collision_mask = 2  # player body layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# a save loaded after this clue was already searched must stay consumed
	if PlayerData.has_story_flag(StringName("searched_" + String(spot_id))):
		searched = true


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if not searched:
		_show_prompt("%s  [E]" % prompt_text)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or searched:
		return
	if event.is_action_pressed("interact"):
		search()
		get_viewport().set_input_as_handled()


## Reveal this clue. Returns true only on the first search (idempotent), so a
## reload or a second press never duplicates the entry. Pure-ish: the journal
## write + flags are the only side effects beyond the optional balloon.
func search() -> bool:
	if searched:
		return false
	searched = true
	_hide_prompt()
	PlayerData.set_story_flag(StringName("searched_" + String(spot_id)))
	var fragment := DiggableSpot.choose_lore(lore_text, lore_text_recontext, recontext_revelation)
	if not fragment.is_empty():
		Journal.witness(spot_id, fragment, journal_kind)
	if marks_book_read:
		PlayerData.set_story_flag(book_read_flag)
		# fire the recontext payoff if the knowledge gate is already met; if not,
		# HollowHouseQuest (back in the hall) catches it when more signs are seen.
		HollowHouseQuest.try_fire(revelation_id, doom_prefix, doom_threshold, book_read_flag)
	_play_balloon()
	return true


func _play_balloon() -> void:
	if dialogue_path.is_empty() or not ResourceLoader.exists(dialogue_path):
		return
	GameEvents.exploration_paused.emit()
	DialogueManager.show_dialogue_balloon_scene(BALLOON_SCENE, load(dialogue_path), "start")
	await DialogueManager.dialogue_ended
	GameEvents.exploration_resumed.emit()


func _show_prompt(text: String) -> void:
	if _label == null:
		# own CanvasLayer (follow_viewport) so a dark interior's CanvasModulate
		# cannot crush the prompt to invisibility — same trick as DoorTransition.
		_label_layer = CanvasLayer.new()
		_label_layer.follow_viewport_enabled = true
		add_child(_label_layer)
		_label = Label.new()
		_label.add_theme_font_size_override("font_size", 10)
		_label.add_theme_color_override("font_color", Color(0.9, 0.88, 0.8))
		_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		_label.add_theme_constant_override("outline_size", 3)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label_layer.add_child(_label)
	_label.text = text
	_label.position = global_position + Vector2(-_label.size.x / 2.0, -30.0)
	_label.visible = true
	_label_layer.visible = true


func _hide_prompt() -> void:
	if _label_layer:
		_label_layer.visible = false
