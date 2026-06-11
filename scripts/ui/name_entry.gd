class_name NameEntry
extends CanvasLayer
## One-shot name prompt at the start of a new game. Sets PlayerData.custom_name
## (dialogue speaks it via {{PlayerData.custom_name}}) and the player_named
## story flag, so saves and reloads never ask twice. Pauses exploration like
## StoryDialogue; gated dialogues wait on the flag (wait_for_flag).

const NAMED_FLAG := &"player_named"
const DEFAULT_NAME := "Rowan"
const MAX_NAME_LENGTH := 16

var _line_edit: LineEdit


func _ready() -> void:
	layer = 20  # above HUD (15) and touch controls
	if PlayerData.has_story_flag(NAMED_FLAG):
		queue_free()
		return
	_build_ui()
	_pause_exploration.call_deferred()


func _pause_exploration() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player is PlayerController:
		player.set_movement_state(PlayerController.MovementState.CUTSCENE)
	if GameEvents:
		GameEvents.exploration_paused.emit()


func _build_ui() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.04, 0.85)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.custom_minimum_size = Vector2(280, 0)
	panel.add_child(box)

	var prompt := Label.new()
	prompt.text = "They picked you by name.\nWhat is it?"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(prompt)

	_line_edit = LineEdit.new()
	_line_edit.text = DEFAULT_NAME
	_line_edit.max_length = MAX_NAME_LENGTH
	_line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_line_edit.select_all_on_focus = true
	_line_edit.text_submitted.connect(func(text: String) -> void: _confirm(text))
	box.add_child(_line_edit)

	var begin := Button.new()
	begin.text = "Run"
	begin.pressed.connect(func() -> void: _confirm(_line_edit.text))
	box.add_child(begin)

	_line_edit.grab_focus.call_deferred()


func _confirm(raw_name: String) -> void:
	apply_name(raw_name)
	var player := get_tree().get_first_node_in_group("player")
	if player is PlayerController:
		player.set_movement_state(PlayerController.MovementState.EXPLORING)
	if GameEvents:
		GameEvents.exploration_resumed.emit()
	queue_free()


## Pure-ish core, unit-tested: normalizes and stores the chosen name.
static func apply_name(raw_name: String) -> String:
	var trimmed := raw_name.strip_edges().substr(0, MAX_NAME_LENGTH)
	if trimmed.is_empty():
		trimmed = DEFAULT_NAME
	PlayerData.custom_name = trimmed
	PlayerData.set_story_flag(NAMED_FLAG)
	return trimmed
