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


func _play_beat() -> void:
	if GameEvents:
		GameEvents.horror_stinger.emit(&"first_glimpse")
	DreadManager.add_dread(dread_spike, &"dread_beat")

	var stinger := get_node_or_null(stinger_player_path) as AudioStreamPlayer
	if stinger:
		stinger.play()

	for path in fog_nodes:
		var fog := get_node_or_null(path) as CanvasItem
		if fog:
			var target := fog.modulate
			fog.modulate.a = 0.0
			fog.visible = true
			create_tween().tween_property(fog, "modulate:a", target.a if target.a > 0.05 else 0.45, 2.5)

	var silhouette := get_node_or_null(silhouette_path) as Node2D
	if silhouette:
		# place AHEAD of wherever the player actually crossed — a fixed world
		# position can be off-screen (playtest 2026-06-10)
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player:
			silhouette.global_position = player.global_position + Vector2(170, -36)
		silhouette.modulate.a = 0.0
		silhouette.visible = true
		var tween := create_tween()
		tween.tween_property(silhouette, "modulate:a", 0.9, 0.5)
		tween.tween_interval(0.8)
		tween.tween_property(silhouette, "modulate:a", 0.0, 0.7)
		tween.tween_callback(func() -> void: silhouette.visible = false)
