extends GutTest
## Ambient + event sound wiring (Wiring & Audibility pass, item 3). Audio playback
## is an F5 check; here we assert the WIRING fires via the new Sfx.played signal.
## Monster sounds + the doom bell were already wired — these lock them in with
## tests; crickets/owl/campfire are the newly-wired night bed.

const AdaptiveAudioT := preload("res://scripts/autoload/adaptive_audio.gd")

var _played: Array[StringName] = []


func _rec(n: StringName) -> void:
	_played.append(n)


func before_each() -> void:
	_played.clear()
	Sfx.played.connect(_rec)


func after_each() -> void:
	if Sfx.played.is_connected(_rec):
		Sfx.played.disconnect(_rec)
	HollowingClock.stage = HollowingClock.Stage.QUIET
	HollowingClock.alarm_points = 0.0


# --- doom bell (already wired; locked in) ---

func test_bell_tolls_on_stage_advance() -> void:
	HollowingClock.stage = HollowingClock.Stage.QUIET
	HollowingClock.alarm_points = 0.0
	HollowingClock._dialogue_open = false
	HollowingClock._in_hideout = false
	HollowingClock.add_alarm(HollowingClock.ALARM_THRESHOLD)  # one stage's worth
	assert_gt(HollowingClock.stage, HollowingClock.Stage.QUIET, "a stage advanced")
	assert_true(_played.has(&"bell_toll"), "the chapel bell tolls the doom on a stage advance")


# --- monster lunge (already wired; locked in) ---

func test_monster_lunge_plays_attack_sound() -> void:
	var enemy: EnemyBase = preload("res://scenes/enemies/twisted_child.tscn").instantiate()
	add_child_autofree(enemy)
	await wait_physics_frames(1)
	_played.clear()
	enemy._attack_enter()
	assert_true(_played.has(&"monster_attack"), "the lunge plays the monster attack sound")


# --- owl night stinger (newly wired) ---

func test_owl_due_rules() -> void:
	var L := AdaptiveAudioT.Layer
	assert_true(AdaptiveAudioT.owl_due(30.0, 24.0, false, L.AMBIENT), "due once the timer passes its gap")
	assert_false(AdaptiveAudioT.owl_due(10.0, 24.0, false, L.AMBIENT), "not due before the gap")
	assert_false(AdaptiveAudioT.owl_due(30.0, 24.0, true, L.AMBIENT), "silent inside the hideout")
	assert_false(AdaptiveAudioT.owl_due(30.0, 24.0, false, L.DANGER), "owls hush near a threat")


# --- campfire crackle (newly wired) ---

func test_campfire_crackle_on_the_hideout_fire() -> void:
	var zone: Node2D = load("res://scenes/zones/playground_fringes.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var crackle := zone.get_node_or_null("Hideout/Campfire/Crackle") as AudioStreamPlayer2D
	assert_not_null(crackle, "the hideout fire has a crackle audio player")
	assert_not_null(crackle.stream, "with a stream assigned")
	assert_true(crackle.autoplay, "autoplaying (loop-enabled import)")
