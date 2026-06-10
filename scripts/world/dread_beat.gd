class_name DreadBeat
extends Area2D
## One-shot scripted horror beat: stinger audio + dread spike + fog roll-in +
## a brief monster silhouette glimpse. Fires once per save (story flag).

@export var beat_flag: StringName = &"first_dread_beat"
@export var dread_spike: float = 25.0
@export var fog_nodes: Array[NodePath] = []
@export var silhouette_path: NodePath
@export var stinger_player_path: NodePath


func _ready() -> void:
	monitoring = true
	collision_mask = 2  # player body layer
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or PlayerData.has_story_flag(beat_flag):
		return
	PlayerData.set_story_flag(beat_flag)
	_play_beat()


## Ordered so each element is readable (playtest 2026-06-10: a near-black
## sprite under simultaneous fog tween was invisible):
## stinger -> Briar barks at it -> silhouette ahead on the path -> fog rolls in.
func _play_beat() -> void:
	if GameEvents:
		GameEvents.horror_stinger.emit(&"first_glimpse")
	DreadManager.add_dread(dread_spike, &"dread_beat")
	if WorldState.time_of_day == WorldState.TimeOfDay.DUSK:
		WorldState.advance_time()  # night falls with the first glimpse

	var stinger := get_node_or_null(stinger_player_path) as AudioStreamPlayer
	if stinger:
		stinger.play()

	# the companion sees it first — directs the player's eyes
	var companion := get_tree().get_first_node_in_group("companion") as CompanionBase
	if companion and companion.hsm:
		companion.hsm.dispatch(&"alert")

	var silhouette := get_node_or_null(silhouette_path) as Node2D
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if silhouette:
		# directly ahead on the path at the player's height — unmissable
		if player:
			silhouette.global_position = player.global_position + Vector2(150, 0)
		silhouette.scale = Vector2(4, 4)
		# dark violet, not pure black: reads against the dusk ground
		silhouette.modulate = Color(0.22, 0.12, 0.3, 0.0)
		silhouette.visible = true
		var tween := create_tween()
		tween.tween_property(silhouette, "modulate:a", 1.0, 0.4)
		tween.tween_interval(1.3)
		tween.tween_property(silhouette, "modulate:a", 0.0, 0.8)
		tween.tween_callback(func() -> void: silhouette.visible = false)

	# fog arrives AFTER the glimpse registered
	var fog_tween := create_tween()
	fog_tween.tween_interval(1.6)
	fog_tween.tween_callback(func() -> void:
		for path in fog_nodes:
			var fog := get_node_or_null(path) as CanvasItem
			if fog:
				var target := fog.modulate
				fog.modulate.a = 0.0
				fog.visible = true
				create_tween().tween_property(
					fog, "modulate:a", target.a if target.a > 0.05 else 0.45, 2.5)
	)
