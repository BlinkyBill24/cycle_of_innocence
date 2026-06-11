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
