class_name DoorTransition
extends Area2D
## A door / stairs / ladder / exit — one component for every threshold
## (accessible-interiors). On trigger it asks ZoneManager to load `target_scene`
## and place the player at the destination's "spawn_<spawn_id>" marker. The same
## node serves exterior-door→interior, interior-stairs→floor, and exit→world;
## only the target scene + spawn id differ.
##
## INTERACT mode: player walks onto it, presses the interact key. ENTER mode:
## triggers on contact (seamless thresholds). `locked` blocks entry and floats
## a diegetic reason — restraint for buildings with no authored interior.

enum Mode { INTERACT, ENTER }

@export var target_scene: PackedScene
## Alternative to target_scene: a scene path string. Use this for floors that
## reference each other (stairs up/down) to avoid a circular PackedScene load.
## target_scene wins if both are set.
@export_file("*.tscn") var target_scene_path: String = ""
@export var spawn_id: StringName = &"default"
@export var mode: Mode = Mode.INTERACT
@export var locked := false
@export_multiline var locked_reason := "The door is locked."
## Shown floating over the door in INTERACT mode while the player stands on it.
@export var prompt_text := "Enter"

var _player_inside := false
var _label: Label


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player body layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if mode == Mode.ENTER:
		trigger()
	else:
		_show_prompt(locked_reason if locked else "%s  [E]" % prompt_text)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_hide_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if mode != Mode.INTERACT or not _player_inside:
		return
	if event.is_action_pressed("interact"):
		trigger()
		get_viewport().set_input_as_handled()


## Attempt the transition. Returns false when locked (blocked). Static-ish:
## the actual scene swap is ZoneManager's deferred change_scene.
func trigger() -> bool:
	if locked:
		_show_prompt(locked_reason)
		return false
	var path := target_path()
	if path.is_empty():
		push_warning("DoorTransition '%s': no target_scene set" % name)
		return false
	ZoneManager.go_to_scene(path, spawn_id)
	return true


## The target scene's resource path (empty if unset). Pure — testable.
## target_scene (PackedScene) wins; else the target_scene_path string.
func target_path() -> String:
	if target_scene:
		return target_scene.resource_path
	return target_scene_path


func _show_prompt(text: String) -> void:
	if _label == null:
		_label = Label.new()
		_label.add_theme_font_size_override("font_size", 10)
		_label.add_theme_color_override("font_color", Color(0.9, 0.88, 0.8))
		_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		_label.add_theme_constant_override("outline_size", 3)
		_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label.z_as_relative = false
		_label.z_index = 200
		add_child(_label)
	_label.text = text
	_label.position = Vector2(-_label.size.x / 2.0, -34)
	_label.visible = true


func _hide_prompt() -> void:
	if _label:
		_label.visible = false
