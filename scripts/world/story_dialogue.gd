class_name StoryDialogue
extends Node
## Plays a one-shot story dialogue (Dialogue Manager) gated by a story flag.
## Pauses player exploration while the balloon is open.

const BALLOON_SCENE := "res://scenes/ui/dialogue_balloon.tscn"

@export_file("*.dialogue") var dialogue_path: String
@export var title: String = "start"
@export var once_flag: StringName = &""
@export var start_delay: float = 1.2
@export var autostart: bool = true
## Optional gate: don't start until this story flag is set (e.g. player_named
## while the NameEntry prompt is open).
@export var wait_for_flag: StringName = &""

var _running := false


func _ready() -> void:
	if autostart:
		_try_start.call_deferred()


func _try_start() -> void:
	if _running or dialogue_path.is_empty():
		return
	if not once_flag.is_empty() and PlayerData.has_story_flag(once_flag):
		return
	_running = true
	while not wait_for_flag.is_empty() and not PlayerData.has_story_flag(wait_for_flag):
		await get_tree().process_frame
	await get_tree().create_timer(start_delay).timeout
	var player := get_tree().get_first_node_in_group("player")
	if player is PlayerController:
		player.set_movement_state(PlayerController.MovementState.CUTSCENE)
	if GameEvents:
		GameEvents.exploration_paused.emit()
	DialogueManager.show_dialogue_balloon_scene(BALLOON_SCENE, load(dialogue_path), title)
	await DialogueManager.dialogue_ended
	if not once_flag.is_empty():
		PlayerData.set_story_flag(once_flag)
	if player is PlayerController:
		player.set_movement_state(PlayerController.MovementState.EXPLORING)
	if GameEvents:
		GameEvents.exploration_resumed.emit()
	_running = false
