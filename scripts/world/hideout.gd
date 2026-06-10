class_name Hideout
extends Area2D
## The safe-camp under the roots (docs/mechanics/day-night-hideout.md):
## campfire warmth, the hideout_warm stem, and two care interactions —
## REST (sleep to dawn + save + heal + dread relief) and PLAY with Briar
## (bond up, corruption down). The found-family scenes live here.

signal rested

const REST_BOND := 2.0
const REST_CORRUPTION := -4.0
const PLAY_BOND := 3.0
const PLAY_CORRUPTION := -2.0
const PLAY_COOLDOWN := 8.0

var player_inside := false
var _play_cooldown := 0.0
var _fade_rect: ColorRect


func _ready() -> void:
	add_to_group("hideout")
	monitoring = true
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_play_cooldown = maxf(_play_cooldown - delta, 0.0)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		DreadManager.reduce_dread(10.0)  # the fire pushes the dark back a little
		AdaptiveAudio.set_hideout(true)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		AdaptiveAudio.set_hideout(false)


## Player interact inside the camp: near the fire = rest; near Briar = play.
func try_interact(player: Node2D) -> bool:
	if not player_inside:
		return false
	var briar := get_tree().get_first_node_in_group("briar") as CompanionBase
	if briar and player.global_position.distance_to(briar.global_position) < 36.0 \
			and _play_cooldown <= 0.0:
		_play_with(briar)
		return true
	if player.global_position.distance_to(global_position) < 56.0:
		_rest(player)
		return true
	return false


func _play_with(briar: CompanionBase) -> void:
	_play_cooldown = PLAY_COOLDOWN
	PlayerData.add_companion_bond(briar.companion_id, PLAY_BOND)
	PlayerData.add_companion_corruption(briar.companion_id, PLAY_CORRUPTION)
	Sfx.play(&"bark", 0.0)
	DreadManager.reduce_dread(5.0)
	if briar.hsm and briar.hsm.get_active_state() == briar._state_follow:
		briar.hsm.dispatch(&"alert")  # happy bark + hop reuses the telegraph


func _rest(player: Node2D) -> void:
	_fade(true)
	await get_tree().create_timer(0.9).timeout
	WorldState.sleep_to_dawn()
	DreadManager.reset()
	var briar_id := &"briar"
	PlayerData.add_companion_bond(briar_id, REST_BOND)
	PlayerData.add_companion_corruption(briar_id, REST_CORRUPTION)
	if player is PlayerController:
		(player as PlayerController).health.restore_full()
	SaveManager.save_game()
	rested.emit()
	await get_tree().create_timer(0.5).timeout
	_fade(false)


func _fade(to_black: bool) -> void:
	if _fade_rect == null:
		var layer := CanvasLayer.new()
		layer.layer = 30
		add_child(layer)
		_fade_rect = ColorRect.new()
		_fade_rect.color = Color(0, 0, 0, 0)
		_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_fade_rect)
	create_tween().tween_property(_fade_rect, "color:a", 1.0 if to_black else 0.0, 0.8)
