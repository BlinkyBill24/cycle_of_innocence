extends GutTest
## ZoneRoot camera clamp (prop-coherence fix plan item 2): the player camera
## must be limited to the painted GroundBackdrop rect (+bleed) so the void
## past the world edge never shows; zones without a backdrop must reset
## limits so the previous zone's clamp can't leak through a transition.

const ZR := preload("res://scripts/world/zone_root.gd")

var _prev_zone_id: StringName
var _prev_arriving: StringName


func before_each() -> void:
	_prev_zone_id = ZoneManager.current_zone_id
	_prev_arriving = ZoneManager.arriving_from


func after_each() -> void:
	# ZoneRoot._ready registers our throwaway zones with the global
	# ZoneManager — restore so later test scripts see unchanged state
	ZoneManager.current_zone_id = _prev_zone_id
	ZoneManager.arriving_from = _prev_arriving


func test_world_rect_centered_at_origin() -> void:
	# the real backdrops: centered Sprite2D at (0,0), scale 1 — e.g. the
	# village backdrop is 1408x896 -> rect (-704,-448)..(704,448)
	var rect := ZR.sprite_world_rect(
		Vector2(1408, 896), Vector2.ZERO, Vector2.ONE, Vector2.ZERO, true
	)
	assert_eq(rect.position, Vector2(-704, -448))
	assert_eq(rect.end, Vector2(704, 448))


func test_world_rect_uncentered_with_scale_and_offset() -> void:
	# top-left anchored, scaled 2x, offset applies in local (pre-scale) space
	var rect := ZR.sprite_world_rect(
		Vector2(100, 50), Vector2(10, 20), Vector2(2, 2), Vector2(5, 5), false
	)
	assert_eq(rect.position, Vector2(20, 30))  # 10+5*2, 20+5*2
	assert_eq(rect.size, Vector2(200, 100))


func test_camera_limits_add_bleed_and_round_outward() -> void:
	var limits: Dictionary = ZR.camera_limits(
		Rect2(Vector2(-704.5, -448), Vector2(1409, 896)), 16.0
	)
	assert_eq(int(limits["left"]), -721)   # floor(-704.5 - 16)
	assert_eq(int(limits["top"]), -464)
	assert_eq(int(limits["right"]), 721)   # ceil(704.5 + 16)
	assert_eq(int(limits["bottom"]), 464)


func test_zone_with_backdrop_clamps_player_camera() -> void:
	var zone := await _make_zone_with_player()
	var tex := ImageTexture.create_from_image(
		Image.create(200, 100, false, Image.FORMAT_RGBA8)
	)
	var backdrop := Sprite2D.new()
	backdrop.name = "GroundBackdrop"
	backdrop.texture = tex
	zone.add_child(backdrop)
	zone._clamp_camera_to_backdrop()
	var camera: Camera2D = _camera(zone)
	assert_eq(camera.limit_left, int(-100 - ZR.CAMERA_BLEED))
	assert_eq(camera.limit_right, int(100 + ZR.CAMERA_BLEED))
	assert_eq(camera.limit_top, int(-50 - ZR.CAMERA_BLEED))
	assert_eq(camera.limit_bottom, int(50 + ZR.CAMERA_BLEED))


func test_zone_without_backdrop_resets_limits() -> void:
	var zone := await _make_zone_with_player()
	var camera: Camera2D = _camera(zone)
	camera.limit_left = -10  # stale clamp from a previous zone
	camera.limit_right = 10
	zone._clamp_camera_to_backdrop()
	assert_eq(camera.limit_left, -ZR.LIMIT_OFF)
	assert_eq(camera.limit_right, ZR.LIMIT_OFF)
	assert_eq(camera.limit_top, -ZR.LIMIT_OFF)
	assert_eq(camera.limit_bottom, ZR.LIMIT_OFF)


func _make_zone_with_player() -> ZoneRoot:
	var zone: ZoneRoot = ZR.new()
	var player := Node2D.new()
	player.add_to_group("player")
	var camera := Camera2D.new()
	camera.name = "Camera2D"  # code-added nodes get @-mangled auto names
	player.add_child(camera)
	zone.add_child(player)
	add_child_autofree(zone)  # in-tree: ZoneRoot._ready needs the tree
	# drain ZoneRoot._ready's deferred calls while the zone is still alive
	await wait_frames(1)
	return zone


func _camera(zone: ZoneRoot) -> Camera2D:
	var player := zone.get_tree().get_first_node_in_group("player") as Node2D
	return player.get_node("Camera2D") as Camera2D
