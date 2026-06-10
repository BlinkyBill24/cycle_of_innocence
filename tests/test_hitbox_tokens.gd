extends GutTest
## Regression tests for the Codex-gate findings: hitbox activation tokens.

var hitbox: Hitbox
var shape: CollisionShape2D


func before_each() -> void:
	hitbox = Hitbox.new()
	shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	hitbox.add_child(shape)
	add_child_autofree(hitbox)
	await wait_physics_frames(1)


func test_deactivate_cancels_pending_window() -> void:
	hitbox.activate(0.05)
	await wait_physics_frames(1)
	assert_false(shape.disabled, "window open after activate")
	hitbox.deactivate()
	await wait_physics_frames(1)
	assert_true(shape.disabled, "deactivate closes immediately")


func test_stale_activation_timer_cannot_close_newer_window() -> void:
	hitbox.activate(0.05)            # short window: its timer fires first
	hitbox.activate(0.5)             # newer, longer window
	await wait_seconds(0.15)         # old timer has fired by now
	assert_false(shape.disabled, "older expired window must not close the newer one")
	hitbox.deactivate()
