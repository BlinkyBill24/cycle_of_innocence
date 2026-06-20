extends GutTest
## Push-to-open doors (deliberate friction): a PUSH-mode DoorTransition needs a
## short HELD lean-in — it never opens on a tap. INTERACT/ENTER doors are unchanged.

const DoorScript := preload("res://scripts/world/door_transition.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func _push_door() -> DoorTransition:
	var d: DoorTransition = DoorScript.new()
	d.mode = DoorTransition.Mode.PUSH
	d.push_seconds = 0.6
	add_child_autofree(d)
	d._player_inside = true  # the player is standing in the doorway, leaning in
	return d


func test_push_door_stays_shut_on_a_tap() -> void:
	var d := _push_door()
	assert_true(d._push_active(), "a leaned-on push door is mid-lean")
	d._accumulate_push(0.1)  # a tap — well under push_seconds
	assert_false(d._opened, "a tap does NOT open it")
	assert_lt(d.push_progress(), 1.0, "still mid-push, not given")


func test_push_door_opens_after_a_held_push() -> void:
	var d := _push_door()
	d._accumulate_push(0.3)
	assert_false(d._opened, "halfway is not enough")
	d._accumulate_push(0.3)  # total 0.6 >= push_seconds
	assert_true(d._opened, "a sustained push opens it")
	assert_eq(d.push_progress(), 1.0, "fully pushed")


func test_releasing_resets_the_push() -> void:
	var d := _push_door()
	d._accumulate_push(0.4)
	d._on_body_exited(_player_body())  # let go (walk off the threshold)
	assert_eq(d.push_progress(), 0.0, "stepping off resets the lean — start over")


func test_normal_doors_never_enter_the_push_path() -> void:
	var interact: DoorTransition = DoorScript.new()
	add_child_autofree(interact)
	interact._player_inside = true
	assert_eq(interact.mode, DoorTransition.Mode.INTERACT, "default door is still INTERACT")
	assert_false(interact._push_active(), "an INTERACT door never accumulates a push")
	var enter: DoorTransition = DoorScript.new()
	enter.mode = DoorTransition.Mode.ENTER
	add_child_autofree(enter)
	enter._player_inside = true
	assert_false(enter._push_active(), "an ENTER door never accumulates a push")


func _player_body() -> Node2D:
	var b := CharacterBody2D.new()
	b.add_to_group("player")
	add_child_autofree(b)
	return b
