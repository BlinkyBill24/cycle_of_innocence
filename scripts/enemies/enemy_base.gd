class_name EnemyBase
extends CharacterBody2D
## Base enemy: LimboAI HSM (patrol / chase / attack / hurt) driven by player
## proximity + line of sight. Carries the mercy stubs (Recognition/Stilled)
## that docs/mechanics/encounters-mercy.md fills in at M3.

@export var enemy_kind: StringName = &"twisted_child"
@export var move_speed: float = 35.0
@export var chase_speed: float = 65.0
@export var lunge_speed: float = 170.0
@export var detection_radius: float = 110.0
@export var lose_radius: float = 190.0
@export var attack_range: float = 26.0
@export var attack_cooldown: float = 1.4
@export var wander_radius: float = 50.0
@export var hurt_seconds: float = 0.25

## Mercy system (encounters-mercy.md): Recognition fills via soothing;
## at threshold the monster becomes Stilled (persisted via story flag).
## The generic lullaby plateaus — each child has ONE specific key (its buried
## past, a dug-up story flag) that lets Recognition fill all the way.
@export var spareable: bool = true
@export var stable_id: StringName = &"twisted_child_01"  # unique per placed enemy
@export var soothe_key_flag: StringName = &"dug_playground_buried_toy"
@export var secret_spot_path: NodePath  # where the Stilled child leads Rowan
const RECOGNITION_MAX := 100.0
const GENERIC_PLATEAU := 60.0
const SOOTHE_SLOW_FACTOR := 0.45
const LEAD_TRIGGER_RANGE := 90.0
# Stop BESIDE the spot, not on it — parking on the marker hides it and the
# dig must stay Briar's moment (playtest 2026-06-11).
const LEAD_ARRIVE_DISTANCE := 20.0
const DOMINATED_LIFETIME := 45.0
## Monster-glance cue (encounters-mercy stall hint): when the generic lullaby
## stalls at the plateau, the child briefly turns toward its buried key — a wordless
## "look there" so the stall reads as "find its key", not a broken verb. No UI.
const GLANCE_SECONDS := 0.7
const GLANCE_COOLDOWN := 3.0
var recognition: float = 0.0
var stilled: bool = false
var dominated: bool = false
var _soothe_hold: float = 0.0  # >0 while the lullaby is actively reaching it
var _glance_timer: float = 0.0
var _glance_cooldown: float = 0.0
var _leading: bool = false
var _dominated_life: float = 0.0
var _fought_once: bool = false
var _crumbling: bool = false
var _thrall_lunge_anim: float = 0.0  # dominated lunges happen outside Attack state
## True while a modal owns the world (satchel/journal/dialogue/name entry) — the
## monster freezes body AND brain so it can't chase or lunge from under a menu.
var _paused: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var lunge_hitbox: Hitbox = $LungeHitbox
@onready var los_ray: RayCast2D = $LineOfSight

var hsm: LimboHSM
var _spawn: Vector2
var _wander_target: Vector2
var _wander_wait: float = 0.0
var _cooldown: float = 0.0
var _hurt_timer: float = 0.0
var _lunge_dir: Vector2 = Vector2.ZERO
var _facing: Vector2 = Vector2.DOWN

var _state_patrol: LimboState
var _state_chase: LimboState
var _state_attack: LimboState
var _state_hurt: LimboState
var _state_stilled: LimboState
var _state_dominated: LimboState


func _ready() -> void:
	add_to_group("enemy")
	if PlayerData.has_story_flag(_dominated_flag()):
		queue_free()  # it fought for a Vessel once, then died — it stays dead
		return
	_spawn = global_position
	_wander_target = _spawn
	health.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)
	_init_hsm()
	if GameEvents:
		GameEvents.hollowing_stage_advanced.connect(_on_hollowing_advanced)
		# Freeze while a menu/dialogue owns the world (playtest 2026-06-20: monsters
		# kept chasing while the satchel was open). Mirrors player/companion pause.
		GameEvents.exploration_paused.connect(_on_world_paused)
		GameEvents.exploration_resumed.connect(_on_world_resumed)
	if PlayerData.has_story_flag(_stilled_flag()):
		if HollowingClock.stage >= HollowingClock.RE_AGGRO_STAGE:
			# Frenzy world: the Hunger already took it back while Rowan was away
			PlayerData.story_flags.erase(_stilled_flag())
		else:
			stilled = true
			recognition = RECOGNITION_MAX
			hsm.dispatch(&"stilled")


func _init_hsm() -> void:
	hsm = LimboHSM.new()
	add_child(hsm)

	_state_patrol = LimboState.new().named("Patrol") \
		.call_on_enter(_patrol_enter).call_on_update(_patrol_update)
	_state_chase = LimboState.new().named("Chase").call_on_update(_chase_update)
	_state_attack = LimboState.new().named("Attack") \
		.call_on_enter(_attack_enter).call_on_update(_attack_update)
	_state_hurt = LimboState.new().named("Hurt") \
		.call_on_enter(_hurt_enter).call_on_update(_hurt_update)
	_state_stilled = LimboState.new().named("Stilled") \
		.call_on_enter(_stilled_enter).call_on_update(_stilled_update)
	_state_dominated = LimboState.new().named("Dominated") \
		.call_on_enter(_dominated_enter).call_on_update(_dominated_update)

	for state: LimboState in [_state_patrol, _state_chase, _state_attack, _state_hurt,
			_state_stilled, _state_dominated]:
		hsm.add_child(state)

	hsm.add_transition(_state_patrol, _state_chase, &"spotted")
	hsm.add_transition(_state_chase, _state_patrol, &"lost")
	hsm.add_transition(_state_chase, _state_attack, &"in_range")
	hsm.add_transition(_state_attack, _state_chase, &"attack_done")
	hsm.add_transition(hsm.ANYSTATE, _state_hurt, &"hit")
	hsm.add_transition(_state_hurt, _state_chase, &"recovered")
	hsm.add_transition(hsm.ANYSTATE, _state_stilled, &"stilled")
	hsm.add_transition(_state_stilled, _state_patrol, &"hunger_reasserts")
	hsm.add_transition(hsm.ANYSTATE, _state_dominated, &"dominated")
	hsm.add_transition(_state_hurt, _state_dominated, &"recovered_dominated")

	hsm.initial_state = _state_patrol
	hsm.initialize(self)
	hsm.set_active(true)


func _physics_process(delta: float) -> void:
	if _paused:
		velocity = Vector2.ZERO  # body frozen; the brain (HSM) is stopped too
		return
	_cooldown = maxf(_cooldown - delta, 0.0)
	_soothe_hold = maxf(_soothe_hold - delta, 0.0)
	_glance_cooldown = maxf(_glance_cooldown - delta, 0.0)
	_thrall_lunge_anim = maxf(_thrall_lunge_anim - delta, 0.0)
	# Stilled monsters don't run physics: a zero-velocity CharacterBody2D still
	# depenetrates from overlaps, so walking into one would drag it along
	# (playtest 2026-06-10).
	if not stilled or _leading:
		move_and_slide()
	_update_glance(delta)
	_update_animation()
	_update_recognition_tint()


## Glance-at-buried-key cue: while being soothed and stalled at the plateau, start
## a brief glance toward the secret spot, and aim `_facing` there so the look reads.
func _update_glance(delta: float) -> void:
	var spot := get_node_or_null(secret_spot_path) as Node2D
	if _glance_timer > 0.0:
		_glance_timer -= delta
		if spot:
			_facing = global_position.direction_to(spot.global_position)
		return
	if _soothe_hold <= 0.0 or _glance_cooldown > 0.0:
		return
	var has_key := PlayerData.has_story_flag(soothe_key_flag)
	if should_glance_at_secret(recognition, GENERIC_PLATEAU, stilled, has_key, spot != null):
		_glance_timer = GLANCE_SECONDS
		_glance_cooldown = GLANCE_COOLDOWN


## Pure (testable): glance toward the buried key only when the generic lullaby has
## actually plateaued — recognition at the cap, no key yet, not already Stilled,
## and there IS a secret to point at.
static func should_glance_at_secret(
	recognition_v: float, plateau: float, is_stilled: bool, has_key: bool, has_secret: bool
) -> bool:
	return has_secret and not has_key and not is_stilled and recognition_v >= plateau


func _update_recognition_tint() -> void:
	# visible soothe feedback: the creature pales toward calm as Recognition grows
	if dominated:
		sprite.modulate = Color(1.05, 0.68, 0.68)  # obedience out of fear
		return
	if stilled:
		sprite.modulate = Color(0.85, 0.95, 1.1)
		return
	sprite.modulate = Color.WHITE.lerp(Color(0.82, 0.92, 1.08), (recognition / RECOGNITION_MAX) * 0.8)


# --- perception helpers (pure-ish; unit-tested) ---

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func distance_to_player() -> float:
	var player := get_player()
	return global_position.distance_to(player.global_position) if player else INF


func can_see_player() -> bool:
	var player := get_player()
	if player == null or stilled or dominated:
		return false
	# the world hunts harder as the Hollowing advances
	if distance_to_player() > detection_radius * (1.0 + 0.1 * HollowingClock.stage):
		return false
	los_ray.target_position = to_local(player.global_position)
	los_ray.force_raycast_update()
	return not los_ray.is_colliding()


# --- states ---

func _patrol_enter() -> void:
	_wander_wait = randf_range(0.4, 1.4)


func _patrol_update(delta: float) -> void:
	if can_see_player():
		Sfx.play(&"monster_creep")  # stalk cue the moment it notices Rowan
		hsm.dispatch(&"spotted")
		return
	if global_position.distance_to(_wander_target) < 4.0:
		_wander_wait -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * delta)
		if _wander_wait <= 0.0:
			_wander_target = _spawn + Vector2(
				randf_range(-wander_radius, wander_radius),
				randf_range(-wander_radius, wander_radius))
			_wander_wait = randf_range(0.4, 1.4)
		return
	velocity = global_position.direction_to(_wander_target) * move_speed


func _chase_update(_delta: float) -> void:
	var player := get_player()
	if player == null or stilled or distance_to_player() > lose_radius:
		hsm.dispatch(&"lost")
		return
	var dist := distance_to_player()
	if dist < attack_range * 0.8:
		# A lunge always ends at body contact (player r10 + enemy r8 = 18px),
		# INSIDE the standoff band — freezing there glued it to the player and
		# every next lunge was point-blank (playtest 2026-06-11). Back out to
		# the hover ring before attacking again.
		velocity = player.global_position.direction_to(global_position) * move_speed
		# pinned against a wall while ready to strike: bite rather than be
		# cornered into harmlessness
		if _cooldown <= 0.0 and _soothe_hold <= 0.0 \
				and get_slide_collision_count() > 0 \
				and get_real_velocity().length() < move_speed * 0.3:
			hsm.dispatch(&"in_range")
		return
	if dist <= attack_range and _cooldown <= 0.0 and _soothe_hold <= 0.0:
		hsm.dispatch(&"in_range")
		return
	if dist <= attack_range * 0.85:
		# standoff: hover just out of reach instead of pressing into the
		# player's body (depenetration glued it to them — playtest)
		velocity = velocity.move_toward(Vector2.ZERO, 500.0 * get_physics_process_delta_time())
		return
	# the lullaby reaches it: hesitates and slows instead of lunging
	var speed := chase_speed * (SOOTHE_SLOW_FACTOR if _soothe_hold > 0.0 else 1.0)
	velocity = global_position.direction_to(player.global_position) * speed


func _attack_enter() -> void:
	Sfx.play(&"monster_attack")
	var player := get_player()
	_lunge_dir = global_position.direction_to(player.global_position) if player else _facing
	_cooldown = attack_cooldown
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("lunge"):
		sprite.play("lunge")
	lunge_hitbox.position = _lunge_dir * 10.0
	lunge_hitbox.activate(0.25)
	_hurt_timer = 0.35  # reused as lunge duration


func _attack_update(delta: float) -> void:
	_hurt_timer -= delta
	velocity = _lunge_dir * lunge_speed * maxf(_hurt_timer / 0.35, 0.0)
	if _hurt_timer <= 0.0:
		hsm.dispatch(&"attack_done")


func _hurt_enter() -> void:
	Sfx.play(&"monster_hurt")
	_hurt_timer = hurt_seconds
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("hurt"):
		sprite.play("hurt")


func _hurt_update(delta: float) -> void:
	_hurt_timer -= delta
	velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)
	if _hurt_timer <= 0.0:
		hsm.dispatch(&"recovered_dominated" if dominated else &"recovered")


func _stilled_enter() -> void:
	velocity = Vector2.ZERO
	lunge_hitbox.deactivate()
	# stop reacting to the player's body entirely; remain solid to the world
	collision_mask = 1
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("stilled"):
		sprite.play("stilled")


## A Stilled child remembers where it came from. When Rowan stays close it
## leads the way to its secret (old home, buried keepsake) — once.
func _stilled_update(_delta: float) -> void:
	_leading = false
	velocity = Vector2.ZERO
	if secret_spot_path.is_empty() or PlayerData.has_story_flag(_led_flag()):
		return
	var spot := get_node_or_null(secret_spot_path) as Node2D
	var player := get_player()
	if spot == null or player == null:
		return
	if global_position.distance_to(player.global_position) > LEAD_TRIGGER_RANGE:
		return
	if global_position.distance_to(spot.global_position) <= LEAD_ARRIVE_DISTANCE:
		# It shows the way and waits — uncovering the keepsake is Briar's dig
		# (the assist + bond reward), never the monster's (playtest 2026-06-11).
		PlayerData.set_story_flag(_led_flag())
		var dig := spot as DiggableSpot
		if GameEvents:
			GameEvents.stilled_led_to_secret.emit(stable_id, dig.spot_id if dig else &"")
		return
	_leading = true
	velocity = global_position.direction_to(spot.global_position) * move_speed * 0.7


func _dominated_enter() -> void:
	collision_mask = 1  # heels beside the player; never shoves them
	_dominated_life = DOMINATED_LIFETIME
	_fought_once = false
	# the same lunge now fights FOR Rowan: an ally hitbox wounds other monsters
	# and never the player (combat.md factions). Its own hurtbox stays enemy, so
	# the thrall remains a normal target and self-exclusion blocks self-hits.
	lunge_hitbox.faction = Faction.ALLY
	lunge_hitbox.deactivate()


## Vessel-path thrall (encounters-mercy.md): obeys out of fear, fights for
## Rowan once, then crumbles. Power now, ending flags later.
func _dominated_update(delta: float) -> void:
	_dominated_life -= delta
	var target := _dominated_target()
	if _crumbling or _dominated_life <= 0.0 or (_fought_once and target == null):
		velocity = Vector2.ZERO
		_crumble()
		return
	if target:
		var dist := global_position.distance_to(target.global_position)
		if dist <= attack_range and _cooldown <= 0.0:
			_fought_once = true
			_cooldown = attack_cooldown
			_lunge_dir = global_position.direction_to(target.global_position)
			lunge_hitbox.position = _lunge_dir * 10.0
			lunge_hitbox.activate(0.25)
			velocity = _lunge_dir * lunge_speed
			_thrall_lunge_anim = 0.25
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("lunge"):
				sprite.play("lunge")
		else:
			velocity = global_position.direction_to(target.global_position) * chase_speed
		return
	var player := get_player()
	if player and global_position.distance_to(player.global_position) > 48.0:
		velocity = global_position.direction_to(player.global_position) * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 400.0 * delta)


func _dominated_target() -> EnemyBase:
	var nearest: EnemyBase = null
	var best := 140.0
	for node in get_tree().get_nodes_in_group("enemy"):
		var other := node as EnemyBase
		if other == null or other == self or other.stilled or other.dominated:
			continue
		var dist := global_position.distance_to(other.global_position)
		if dist < best:
			best = dist
			nearest = other
	return nearest


func _crumble() -> void:
	if _crumbling:
		return
	_crumbling = true
	lunge_hitbox.deactivate()
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("crumble"):
		sprite.play("crumble")
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)


func _stilled_flag() -> StringName:
	return StringName("stilled_" + String(stable_id))


func _dominated_flag() -> StringName:
	return StringName("dominated_" + String(stable_id))


func _led_flag() -> StringName:
	return StringName("led_" + String(stable_id))


## Soothing channel (player hold-to-soothe). Returns true when newly Stilled.
## Without this child's specific key the generic lullaby plateaus — finding
## the key (dig up its past) is the environmental-storytelling payoff.
func add_recognition(amount: float, has_key: bool = false) -> bool:
	if stilled or dominated or not spareable or amount <= 0.0:
		return false
	_soothe_hold = 0.6
	var ceiling := RECOGNITION_MAX if has_key else GENERIC_PLATEAU
	recognition = minf(recognition + amount, maxf(ceiling, recognition))
	if recognition < RECOGNITION_MAX:
		return false
	_become_stilled()
	return true


## Domination channel — the Vessel-tier inversion of soothing. Fear does not
## plateau and does not need the key; that is what makes it tempting.
func add_domination(amount: float) -> bool:
	if stilled or dominated or not spareable or amount <= 0.0:
		return false
	_soothe_hold = 0.6
	recognition = minf(recognition + amount, RECOGNITION_MAX)
	if recognition < RECOGNITION_MAX:
		return false
	_become_dominated()
	return true


func _become_stilled() -> void:
	stilled = true
	PlayerData.set_story_flag(_stilled_flag())
	PlayerData.record_spared(stable_id)
	PlayerData.change_morality(-5.0)
	DreadManager.reduce_dread(10.0)
	if GameEvents:
		GameEvents.monster_stilled.emit(stable_id)
	hsm.dispatch(&"stilled")


func _become_dominated() -> void:
	dominated = true
	PlayerData.record_dominated(stable_id)
	PlayerData.change_morality(8.0)
	PlayerData.add_companion_corruption(&"briar", 5.0)  # Briar watches you rule by fear
	if GameEvents:
		GameEvents.monster_dominated.emit(stable_id)
	hsm.dispatch(&"dominated")


# --- reactions ---

## Frenzy undoes mercy (hollowing-clock.md stage 3): not the player's blow —
## no betrayal cost — but the calm is gone and the child hunts again.
func _on_hollowing_advanced(new_stage: int) -> void:
	if new_stage >= HollowingClock.RE_AGGRO_STAGE and stilled:
		stilled = false
		recognition = 0.0
		collision_mask = 7
		PlayerData.story_flags.erase(_stilled_flag())
		hsm.dispatch(&"hunger_reasserts")


func _on_hit_received(hitbox: Hitbox) -> void:
	if stilled:
		_betrayed()
	velocity = hitbox.global_position.direction_to(global_position) * hitbox.knockback_force
	lunge_hitbox.deactivate()  # interrupted lunge must not keep a live hitbox
	# Re-entering Hurt refreshes the stagger — intended (stun-lock is bounded
	# by Health.invuln_seconds, so hits can't chain faster than 0.2s).
	hsm.dispatch(&"hit")


## Striking a calmed child is the betrayal — the cost lands on the FIRST
## blow, then it wakes and defends itself (encounters-mercy.md).
func _betrayed() -> void:
	stilled = false
	recognition = RECOGNITION_MAX * 0.5  # trust broken, not erased
	collision_mask = 7
	PlayerData.story_flags.erase(_stilled_flag())
	PlayerData.change_morality(20.0)
	PlayerData.add_companion_corruption(&"briar", 10.0)
	if GameEvents:
		GameEvents.stilled_monster_killed.emit(stable_id)


## A modal (satchel/journal/dialogue/name entry) owns the world: stop the body
## AND deactivate the HSM so the monster can't chase, lunge, or animate from under
## a menu. The body gate in _physics_process backs this up (no residual coasting).
func _on_world_paused() -> void:
	_paused = true
	velocity = Vector2.ZERO
	if hsm:
		hsm.set_active(false)


func _on_world_resumed() -> void:
	_paused = false
	if hsm:
		hsm.set_active(true)


func _on_died() -> void:
	if GameEvents:
		GameEvents.enemy_died.emit(enemy_kind)
	queue_free()


# --- visuals ---

func _update_animation() -> void:
	if sprite.sprite_frames == null:
		return
	if _crumbling:
		return  # crumble owns the sprite to the end
	if hsm and hsm.get_active_state() in [_state_attack, _state_hurt]:
		return  # state already chose its animation
	if _thrall_lunge_anim > 0.0:
		return  # dominated lunge owns the sprite for its burst
	if velocity.length() > 4.0:
		_facing = velocity.normalized()
		var anim: Array = PlayerController.directional_anim("walk", _facing)
		sprite.flip_h = anim[1]
		if sprite.sprite_frames.has_animation(anim[0]) and sprite.animation != anim[0]:
			sprite.play(anim[0])
	elif sprite.sprite_frames.has_animation("idle") and sprite.animation != "idle":
		sprite.flip_h = false  # don't leak movement mirroring into poses
		sprite.play("idle")
