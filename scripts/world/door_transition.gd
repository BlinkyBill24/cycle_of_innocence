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

## Optional inventory gate: while set, the door is locked until the player holds
## `unlock_item_id` (Inventory.has). Passing the gate sets `unlock_flag` so the
## door stays open for the rest of the run, and (if `consume_key_on_unlock`)
## spends the key — a single-use key, not a permanent pass you keep in the bag.
@export var unlock_item_id: StringName = &""
## Persistent "already opened" flag (PlayerData story flag). Required so the door
## stays unlocked after its key is consumed, across save/load and re-entry.
@export var unlock_flag: StringName = &""
@export var consume_key_on_unlock := true

var _player_inside := false
var _label: Label
## The prompt lives on its own CanvasLayer (follow_viewport) so a dark interior's
## CanvasModulate (e.g. the basement DarkTint) can't crush it to invisibility.
var _label_layer: CanvasLayer


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
		_show_prompt(locked_reason if is_locked() else "%s  [E]" % prompt_text)


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
	if is_locked():
		_show_prompt(locked_reason)
		return false
	_apply_unlock()  # first pass through an item gate records it + spends the key
	var path := target_path()
	if path.is_empty():
		push_warning("DoorTransition '%s': no target_scene set" % name)
		return false
	ZoneManager.go_to_scene(path, spawn_id)
	return true


## Pure lock rule (testable): a door is locked if it has been opened before
## (`already_unlocked`) it is open for good; else `locked` blocks it, and an
## item gate blocks it until the key is held.
static func compute_locked(
	base_locked: bool, gates_on_item: bool, has_item: bool, already_unlocked: bool
) -> bool:
	if already_unlocked:
		return false
	if base_locked:
		return true
	return gates_on_item and not has_item


## Is this threshold currently blocked? Reads the live inventory + the persistent
## unlock flag; the rule itself lives in compute_locked() for unit tests.
func is_locked() -> bool:
	var already := unlock_flag != &"" and PlayerData.has_story_flag(unlock_flag)
	var has_it := unlock_item_id != &"" and Inventory.has(unlock_item_id)
	return compute_locked(locked, unlock_item_id != &"", has_it, already)


## Record the one-time unlock: set the persistent flag and spend the key. Split
## out of trigger() so the scene-changing path and the unit test share it.
func _apply_unlock() -> void:
	if unlock_flag == &"" or PlayerData.has_story_flag(unlock_flag):
		return
	if unlock_item_id == &"":
		return  # nothing to record for a plain (non-item) door
	PlayerData.set_story_flag(unlock_flag)
	if consume_key_on_unlock and Inventory.has(unlock_item_id):
		Inventory.use(unlock_item_id)  # use() consumes even non-discardable key items


## The target scene's resource path (empty if unset). Pure — testable.
## target_scene (PackedScene) wins; else the target_scene_path string.
func target_path() -> String:
	if target_scene:
		return target_scene.resource_path
	return target_scene_path


func _show_prompt(text: String) -> void:
	if _label == null:
		# own CanvasLayer that tracks the camera — a separate canvas, so the
		# world's CanvasModulate (dark interiors) does not dim the prompt.
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
	# positioned in world coords (the layer follows the viewport), anchored over
	# the door regardless of where the camera is.
	_label.position = global_position + Vector2(-_label.size.x / 2.0, -34.0)
	_label.visible = true
	_label_layer.visible = true


func _hide_prompt() -> void:
	if _label_layer:
		_label_layer.visible = false
