extends GutTest
## Soothe affordance (playtest 2026-06-12 tester-01: "pressing E instead of
## holding it"): the hold verb must be readable on screen — hint when near a
## spareable monster, progress bar while holding, nothing otherwise.

const SP := preload("res://scripts/ui/soothe_prompt.gd")


func test_display_state_rule() -> void:
	var idle: Dictionary = SP.display_state(false, false, 0.0)
	assert_false(bool(idle["visible"]), "nothing shown away from monsters")
	var near: Dictionary = SP.display_state(true, false, 0.0)
	assert_true(bool(near["visible"]))
	assert_string_contains(String(near["text"]), "HOLD", "the verb says HOLD")
	assert_lt(float(near["bar"]), 0.0, "no bar before the hold starts")
	var holding: Dictionary = SP.display_state(true, true, 0.45)
	assert_true(bool(holding["visible"]))
	assert_eq(float(holding["bar"]), 0.45, "bar shows recognition ratio")
	var overflow: Dictionary = SP.display_state(false, true, 1.7)
	assert_eq(float(overflow["bar"]), 1.0, "ratio clamped")


func test_prompt_node_builds_and_updates() -> void:
	var prompt: SoothePrompt = SP.new()
	add_child_autofree(prompt)
	prompt.update_state(true, false, 0.0)
	var label := prompt.get_child(0) as Label
	assert_not_null(label)
	assert_true(label.visible)
	assert_string_contains(label.text, "HOLD")
	prompt.update_state(false, true, 0.6)
	assert_string_contains(label.text, "holding")
	prompt.update_state(false, false, 0.0)
	assert_false(label.visible, "hidden again when out of range")


func test_plateau_discovery_cue() -> void:
	# tester-04: keyless soothe stalls at 60% and re-aggro reads as a bug —
	# the stall must say the lullaby isn't the whole answer
	var stalled: Dictionary = SP.display_state(false, true, 0.6, true)
	assert_string_contains(String(stalled["text"]), "missing")
	assert_true(bool(stalled["stalled"]))
	var rising: Dictionary = SP.display_state(false, true, 0.4, false)
	assert_string_contains(String(rising["text"]), "holding")
	assert_false(bool(rising["stalled"]))
