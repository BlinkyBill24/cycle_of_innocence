extends GutTest
## Village life core (village-life.md): schedule resolution with hollowing
## shifts, suspicion -> alarm conversion (once per villager), gossip pools,
## save round-trip.


func before_each() -> void:
	VillageState.reset()
	HollowingClock.reset()
	WorldState.reset()


func after_each() -> void:
	VillageState.reset()
	HollowingClock.reset()
	WorldState.reset()


# --- schedules ---

func test_normal_slot_resolves() -> void:
	var slot := VillageState.resolve_slot(&"marta_farmer", WorldState.TimeOfDay.DAY, 0)
	assert_eq(slot.marker, &"field_west")
	assert_eq(slot.activity, &"work")


func test_stage2_hardens_the_childs_routine() -> void:
	var before := VillageState.resolve_slot(&"lena_child", WorldState.TimeOfDay.DAY, 0)
	assert_eq(before.marker, &"green_center", "stage 0: children still play outside")
	var after := VillageState.resolve_slot(&"lena_child", WorldState.TimeOfDay.DAY, 2)
	assert_eq(after.marker, &"house_marta", "stage 2: kept indoors")


func test_stage3_stops_a_routine_entirely() -> void:
	var slot := VillageState.resolve_slot(&"marta_farmer", WorldState.TimeOfDay.DAY, 3)
	assert_true(slot.is_empty(), "the empty bench at the usual hour")


func test_unknown_npc_resolves_empty() -> void:
	assert_true(VillageState.resolve_slot(&"nobody", WorldState.TimeOfDay.DAY, 0).is_empty())


func test_search_detail_only_exists_from_stage2() -> void:
	assert_true(VillageState.resolve_slot(&"warden_oslo", WorldState.TimeOfDay.DAY, 0).is_empty(),
			"no search before the village fears")
	assert_true(VillageState.resolve_slot(&"warden_oslo", WorldState.TimeOfDay.DAY, 1).is_empty())
	var slot := VillageState.resolve_slot(&"warden_oslo", WorldState.TimeOfDay.DAY, 2)
	assert_eq(slot.marker, &"search_plaza", "stage 2: the village comes looking")


# --- suspicion ---

func test_suspicion_threshold_reports_exactly_once() -> void:
	watch_signals(VillageState)
	var alarm_before: float = HollowingClock.alarm_points
	VillageState.add_suspicion(&"warden_brek", 60.0)
	assert_eq(HollowingClock.alarm_points, alarm_before, "below threshold: no report")
	VillageState.add_suspicion(&"warden_brek", 60.0)
	assert_signal_emitted_with_parameters(VillageState, "villager_reported", [&"warden_brek"])
	var alarm_after_report: float = HollowingClock.alarm_points
	assert_gt(alarm_after_report, alarm_before, "the clock hears the talk")
	VillageState.add_suspicion(&"warden_brek", 60.0)
	assert_eq(HollowingClock.alarm_points, alarm_after_report, "never reports twice")


func test_caught_eavesdropping_is_worse() -> void:
	assert_eq(VillageState.effective_notice_rate(20.0, false), 20.0)
	assert_eq(VillageState.effective_notice_rate(20.0, true),
			20.0 * VillageState.EAVESDROP_CAUGHT_MULTIPLIER)


func test_eavesdrop_zone_tracks_player_presence() -> void:
	var zone: EavesdropZone = load("res://scripts/world/eavesdrop_zone.gd").new()
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	zone.add_child(shape)
	add_child_autofree(zone)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	zone._on_body_entered(player)
	assert_true(VillageState.player_eavesdropping, "listening is a state")
	zone._on_body_exited(player)
	assert_false(VillageState.player_eavesdropping, "stepping away clears it")


func test_time_decays_suspicion() -> void:
	VillageState.add_suspicion(&"pieter_parent", 50.0)
	WorldState.advance_time()
	assert_almost_eq(VillageState.get_suspicion(&"pieter_parent"),
			50.0 * VillageState.SUSPICION_DECAY_PER_PHASE, 0.01, "rumors quiet with time")


# --- gossip ---

func test_gossip_pools_exist_for_every_stage() -> void:
	for stage in range(4):
		assert_false(VillageState.pick_gossip(stage).is_empty(), "stage %d has lines" % stage)


func test_high_suspicion_changes_the_gossip() -> void:
	var line := VillageState.pick_gossip(0, true)
	assert_string_contains(line, "something small", "the net closing")


# --- persistence ---

func test_suspicion_survives_save_round_trip() -> void:
	VillageState.add_suspicion(&"marta_farmer", 120.0)  # also reports
	var data := VillageState.get_save_data()
	VillageState.reset()
	VillageState.apply_save_data(data)
	assert_eq(VillageState.get_suspicion(&"marta_farmer"), 100.0, "clamped + restored")
	assert_true(VillageState.has_reported(&"marta_farmer"), "report flag persists")


func test_villager_frames_assigned_on_instance_roots() -> void:
	# regression (web playtest 2026-06-11): sprite_frames overrides on the
	# instanced CHILD are dropped by export's binary conversion — invisible
	# villagers in the web build. Frames must be a root-level property.
	for path in ["res://scenes/zones/village_green.tscn",
			"res://scenes/zones/playground_fringes.tscn"]:
		var state: SceneState = (load(path) as PackedScene).get_state()
		for i in state.get_node_count():
			var has_npc_id := false
			var has_frames := false
			for p in state.get_node_property_count(i):
				match String(state.get_node_property_name(i, p)):
					"npc_id":
						has_npc_id = true
					"frames":
						has_frames = true
			if has_npc_id:
				assert_true(has_frames, "%s/%s sets frames on the instance root"
						% [path.get_file(), state.get_node_name(i)])


func test_villager_applies_exported_frames_to_sprite() -> void:
	var villager: Villager = load("res://scenes/npcs/villager.tscn").instantiate()
	villager.frames = load("res://assets/resources/npcs/villager_parent_frames.tres")
	add_child_autofree(villager)
	await wait_physics_frames(1)
	assert_not_null(villager.sprite.sprite_frames, "export var lands on the sprite")


func test_villager_sheets_have_every_routine_animation() -> void:
	for archetype in ["villager_parent", "villager_warden", "villager_elder", "villager_child"]:
		var frames: SpriteFrames = load("res://assets/resources/npcs/%s_frames.tres" % archetype)
		assert_not_null(frames, archetype)
		for anim in ["walk", "idle"]:
			for direction in ["down", "up", "right", "left"]:
				assert_true(frames.has_animation("%s_%s" % [anim, direction]),
						"%s has %s_%s" % [archetype, anim, direction])


# --- villager scene ---

func test_villager_walks_to_scheduled_marker() -> void:
	var marker := Node2D.new()
	marker.add_to_group("marker_field_west")
	add_child_autofree(marker)
	marker.global_position = Vector2(100, 0)
	var villager: Villager = load("res://scenes/npcs/villager.tscn").instantiate()
	villager.npc_id = &"marta_farmer"
	add_child_autofree(villager)
	villager.global_position = Vector2.ZERO
	WorldState.time_of_day = WorldState.TimeOfDay.DAY
	villager.refresh_slot()
	var start := villager.global_position.distance_to(marker.global_position)
	await wait_physics_frames(20)
	assert_lt(villager.global_position.distance_to(marker.global_position), start,
			"closing on the slot marker")


func test_villager_absent_when_marker_not_in_zone() -> void:
	var villager: Villager = load("res://scenes/npcs/villager.tscn").instantiate()
	villager.npc_id = &"elder_aldwin"  # chapel marker does not exist here
	add_child_autofree(villager)
	WorldState.time_of_day = WorldState.TimeOfDay.DAY
	villager.refresh_slot()
	assert_false(villager.visible, "the elder is elsewhere right now")


func test_villager_vanishes_at_stage3_when_stopped() -> void:
	var marker := Node2D.new()
	marker.add_to_group("marker_field_west")
	add_child_autofree(marker)
	var villager: Villager = load("res://scenes/npcs/villager.tscn").instantiate()
	villager.npc_id = &"marta_farmer"
	add_child_autofree(villager)
	WorldState.time_of_day = WorldState.TimeOfDay.DAY
	HollowingClock.stage = 3
	villager.refresh_slot()
	assert_false(villager.visible, "her routine stopped")
