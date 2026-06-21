extends GutTest
## Pickup notice (playtest 2026-06-21): a "Found: <item>" toast on every acquisition so
## a pickup is never silent. The fade is an F5 check; the text + the wiring are tested.

const ToastScript := preload("res://scripts/ui/pickup_toast.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func test_toast_text_names_the_item() -> void:
	assert_eq(ToastScript.toast_text(&"flute"), "Found: Flute", "uses the item's display name")
	assert_eq(ToastScript.toast_text(&"hollow_key"), "Found: Tarnished Key")


func test_toast_text_shows_a_stack_count() -> void:
	assert_eq(ToastScript.toast_text(&"sling_stones", 5), "Found: Sling Stones  ×5")


func test_toast_text_falls_back_to_the_id() -> void:
	assert_eq(ToastScript.toast_text(&"not_a_real_item"), "Found: not_a_real_item")


func test_acquiring_an_item_shows_a_toast() -> void:
	var toast: PickupToast = ToastScript.new()
	add_child_autofree(toast)
	await wait_physics_frames(1)
	assert_null(toast._current, "nothing shown until a pickup")
	GameEvents.item_acquired.emit(&"flute", 1)
	assert_not_null(toast._current, "a pickup raises a toast")
	assert_eq(toast._current.text, "Found: Flute")
