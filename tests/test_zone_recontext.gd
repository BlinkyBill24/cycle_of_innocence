extends GutTest
## Knowledge-gated zones (zone-recontextualization.md): recontext groups
## toggle with revelations — on enter and live on unlock.


func before_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	DreadManager.reset()


func _make_zone_with_secret() -> Array:
	var zone := Node2D.new()
	add_child_autofree(zone)
	var recontext: ZoneRecontext = load("res://scripts/world/zone_recontext.gd").new()
	zone.add_child(recontext)
	var secret := Area2D.new()
	secret.add_to_group("recontext_monsters_are_children")
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	secret.add_child(shape)
	zone.add_child(secret)
	return [recontext, secret]


func test_unknown_revelation_hides_the_node() -> void:
	var pair := _make_zone_with_secret()
	await wait_physics_frames(1)
	var secret := pair[1] as Area2D
	assert_false(secret.visible, "the truth is not visible yet")
	assert_eq(secret.process_mode, Node.PROCESS_MODE_DISABLED)


func test_unlock_recontextualizes_live() -> void:
	var pair := _make_zone_with_secret()
	await wait_physics_frames(1)
	PlayerData.unlock_revelation(&"monsters_are_children")
	var secret := pair[1] as Area2D
	assert_true(secret.visible, "same scene, new truth")
	assert_eq(secret.process_mode, Node.PROCESS_MODE_INHERIT)


func test_not_groups_invert() -> void:
	var zone := Node2D.new()
	add_child_autofree(zone)
	var recontext: ZoneRecontext = load("res://scripts/world/zone_recontext.gd").new()
	zone.add_child(recontext)
	var innocent := Node2D.new()
	innocent.add_to_group("recontext_not_monsters_are_children")
	zone.add_child(innocent)
	await wait_physics_frames(1)
	assert_true(innocent.visible, "pre-truth decor present")
	PlayerData.unlock_revelation(&"monsters_are_children")
	assert_false(innocent.visible, "pre-truth decor withdraws")


func test_whisper_speaks_once_and_flags() -> void:
	var whisper: WhisperSpot = load("res://scripts/world/whisper_spot.gd").new()
	whisper.spot_id = &"test_whisper"
	whisper.text = "..."
	whisper.dread_on_hear = 5.0
	add_child_autofree(whisper)
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	var dread_before: float = DreadManager.dread
	whisper._on_body_entered(player)
	assert_true(PlayerData.has_story_flag(&"whispered_test_whisper"))
	assert_gt(DreadManager.dread, dread_before, "hearing it costs something")
	var dread_after: float = DreadManager.dread
	whisper._on_body_entered(player)
	assert_eq(DreadManager.dread, dread_after, "the world says it once")


func test_playground_carries_the_sandbox_whisper() -> void:
	var state: SceneState = (load("res://scenes/zones/playground_fringes.tscn") as PackedScene).get_state()
	var found := false
	for i in state.get_node_count():
		for group in state.get_node_groups(i):
			if group == "recontext_monsters_are_children":
				found = true
	assert_true(found, "first authored recontext moment is wired")


# --- secret #2: the illegible cult symbol (symbol_literacy gate) ------------

func test_cult_symbol_illegible_until_literacy_learned() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var illegible := zone.get_node("CultSymbolIllegible")
	var legible := zone.get_node("CultSymbolLegible")
	# by default the marks won't resolve — only the illegible read is live
	assert_eq(illegible.process_mode, Node.PROCESS_MODE_INHERIT, "illegible read present by default")
	assert_eq(legible.process_mode, Node.PROCESS_MODE_DISABLED, "no meaning before literacy")
	# learning to read the sigil swaps the reading live (and on next enter)
	PlayerData.unlock_revelation(&"symbol_literacy")
	await wait_physics_frames(1)
	assert_eq(illegible.process_mode, Node.PROCESS_MODE_DISABLED, "the illegible read withdraws")
	assert_eq(legible.process_mode, Node.PROCESS_MODE_INHERIT, "the sigil now reads")


# --- stage-keyed groups (doom-legibility roadmap) -------------------------

func _make_zone_with_stage_sign(group: String) -> Array:
	var zone := Node2D.new()
	add_child_autofree(zone)
	var recontext: ZoneRecontext = load("res://scripts/world/zone_recontext.gd").new()
	zone.add_child(recontext)
	var sign := Area2D.new()
	sign.add_to_group(group)
	zone.add_child(sign)
	return [recontext, sign]


func test_stage_group_hidden_until_stage_reached() -> void:
	HollowingClock.reset()
	var pair := _make_zone_with_stage_sign("recontext_stage_1")
	await wait_physics_frames(1)
	var sign := pair[1] as Area2D
	assert_false(sign.visible, "stage-1 sign absent at stage 0")
	HollowingClock.add_alarm(HollowingClock.ALARM_THRESHOLD)  # -> stage 1
	await wait_physics_frames(1)
	assert_true(sign.visible, "stage-1 sign appears once the bell has rung")
	HollowingClock.reset()


func test_not_stage_group_inverts() -> void:
	HollowingClock.reset()
	var pair := _make_zone_with_stage_sign("recontext_not_stage_1")
	await wait_physics_frames(1)
	var sign := pair[1] as Area2D
	assert_true(sign.visible, "pre-stage-1 decor present at stage 0")
	HollowingClock.add_alarm(HollowingClock.ALARM_THRESHOLD)
	await wait_physics_frames(1)
	assert_false(sign.visible, "pre-stage-1 decor gone once stage 1 hits")
	HollowingClock.reset()


func test_stage_reached_pure() -> void:
	HollowingClock.reset()
	assert_false(ZoneRecontext._stage_reached("2"))
	assert_false(ZoneRecontext._stage_reached("bad"), "non-int suffix is inactive")
