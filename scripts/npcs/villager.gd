class_name Villager
extends CharacterBody2D
## Routine-driven villager (village-life.md): walks to the marker for the
## current time slot, idles there, and NOTICES Rowan — the village believes
## the child is dead, so being seen is the threat, not combat. Suspicion
## feeds the Hollowing clock via VillageState.

const EXCLAIM_TEX := preload("res://assets/sprites/ui/exclaim.png")

@export var npc_id: StringName = &"marta_farmer"
## Archetype SpriteFrames — set on the INSTANCE root, never on the child:
## child overrides are dropped by export's binary scene conversion
## (web playtest 2026-06-11: invisible villagers).
@export var frames: SpriteFrames
@export var move_speed: float = 55.0
@export var notice_radius: float = 70.0
@export var notice_rate: float = 25.0  # suspicion per second while seeing Rowan
@export var arrive_distance: float = 6.0

var _target: Node2D
var _stopped := false  # stage-3: the routine simply ended
var _facing := Vector2.DOWN
var _noticing := false
var _exclaim: Sprite2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var los_ray: RayCast2D = $LineOfSight


func _ready() -> void:
	add_to_group("villager")
	if frames and sprite:
		sprite.sprite_frames = frames
	WorldState.time_changed.connect(func(_t: int, _d: int) -> void: refresh_slot())
	GameEvents.hollowing_stage_advanced.connect(func(_s: int) -> void: refresh_slot())
	refresh_slot()


## Re-resolve the schedule: move target, absence, or stopped routine.
func refresh_slot() -> void:
	var slot := VillageState.resolve_slot(npc_id, WorldState.time_of_day, HollowingClock.stage)
	_stopped = slot.is_empty()
	if _stopped:
		visible = false
		set_physics_process(false)
		return
	var markers := get_tree().get_nodes_in_group("marker_" + String(slot.marker))
	_target = markers[0] as Node2D if not markers.is_empty() else null
	# no marker in this zone = the villager is elsewhere right now
	visible = _target != null
	set_physics_process(_target != null)


func _physics_process(delta: float) -> void:
	_update_notice(delta)
	if _target and global_position.distance_to(_target.global_position) > arrive_distance:
		velocity = global_position.direction_to(_target.global_position) * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	_update_animation()


func _update_notice(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var sees := false
	if player and global_position.distance_to(player.global_position) <= notice_radius:
		los_ray.target_position = to_local(player.global_position)
		los_ray.force_raycast_update()
		sees = not los_ray.is_colliding()
	if sees:
		VillageState.add_suspicion(npc_id, notice_rate * delta)
		_facing = global_position.direction_to(player.global_position)
	if sees != _noticing:
		_noticing = sees
		_show_exclaim(sees)


func _show_exclaim(on: bool) -> void:
	if _exclaim == null:
		_exclaim = Sprite2D.new()
		_exclaim.texture = EXCLAIM_TEX
		_exclaim.position = Vector2(0, -24)
		_exclaim.scale = Vector2(2, 2)
		add_child(_exclaim)
	_exclaim.visible = on


func _update_animation() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	var moving := velocity.length() > 4.0
	if moving:
		_facing = velocity.normalized()
	var anim: Array = PlayerController.directional_anim("walk" if moving else "idle", _facing)
	if sprite.sprite_frames.has_animation(anim[0]) and sprite.animation != anim[0]:
		sprite.play(anim[0])
