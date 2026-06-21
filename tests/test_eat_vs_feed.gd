extends GutTest
## Eat-vs-feed choice (decision 2026-06-21, "ask at point of use"): tapping a
## DUAL-USE food (heals Rowan AND feeds a companion) pops a choice; single-purpose
## items act immediately. These guard the pure decision logic + that BOTH verbs
## still reach their real effect (the feed path was previously unreachable by tap).

const PanelScript := preload("res://scripts/ui/inventory_panel.gd")


func before_each() -> void:
	PlayerData.reset_to_defaults()


func _def(id: StringName) -> ItemDef:
	return ItemRegistry.get_def(id)


func _bond(id: StringName) -> float:
	return float(PlayerData.get_companion(id).bond)


# --- is_dual_use: only the genuinely shared foods ---

func test_is_dual_use_only_for_shared_food() -> void:
	assert_true(PanelScript.is_dual_use(_def(&"dried_meat")), "meat heals AND feeds Briar")
	assert_true(PanelScript.is_dual_use(_def(&"forest_berries")), "berries heal AND feed Briar")
	assert_false(PanelScript.is_dual_use(_def(&"hearty_meal")), "heal-only — no feed")
	assert_false(PanelScript.is_dual_use(_def(&"honeycomb")), "heal-only — no feed")
	assert_false(PanelScript.is_dual_use(_def(&"buried_bone")), "feed-only — no heal value")
	assert_false(PanelScript.is_dual_use(_def(&"flute")), "key item is not food")
	assert_false(PanelScript.is_dual_use(_def(&"sturdy_stick")), "a weapon is not food")
	assert_false(PanelScript.is_dual_use(null), "null is safe")


# --- food_affordance: the verb is never invisible ---

func test_food_affordance_reads_clearly() -> void:
	var dual := PanelScript.food_affordance(_def(&"dried_meat"))
	assert_string_contains(dual.to_lower(), "eat")
	assert_string_contains(dual, "Briar")  # names the companion, not a hard-coded "the dog"
	assert_eq(PanelScript.food_affordance(_def(&"hearty_meal")), "Tap to eat")
	assert_string_contains(PanelScript.food_affordance(_def(&"buried_bone")), "give to Briar")
	assert_eq(PanelScript.food_affordance(_def(&"flute")), "", "non-food has no food affordance")
	assert_eq(PanelScript.food_affordance(_def(&"sturdy_stick")), "", "a weapon has no food affordance")
	assert_eq(PanelScript.food_affordance(null), "")


# --- both outcomes of the choice still do their real thing ---

func test_choosing_feed_raises_companion_bond() -> void:
	# the FEED branch the choice's "Give to Briar" button runs (Inventory.use)
	Inventory.add(&"dried_meat")
	var before := _bond(&"briar")
	assert_true(Inventory.use(&"dried_meat"), "feed succeeds")
	assert_eq(_bond(&"briar"), before + 8.0, "Briar bond +8")
	assert_eq(Inventory.quantity_of(&"dried_meat"), 0, "the fed item is consumed")


func test_choosing_feed_applies_its_morality_cost() -> void:
	Inventory.add(&"dried_meat")
	var m := PlayerData.morality
	Inventory.use(&"dried_meat")
	assert_eq(PlayerData.morality, m - 3.0, "feeding dried meat costs -3 morality (current tuning)")


func test_choosing_eat_does_not_feed_the_companion() -> void:
	# the EAT branch (Inventory.eat) must NOT touch the companion — the heal MAGNITUDE
	# is proven in test_food_healing (which instantiates the player to apply the signal).
	PlayerData.current_hp = 4  # below max so eat is allowed
	var bond := _bond(&"briar")
	Inventory.add(&"forest_berries")
	assert_true(Inventory.eat(&"forest_berries"), "eating an owned food below full succeeds")
	assert_eq(_bond(&"briar"), bond, "eating does NOT feed Briar")
	assert_eq(Inventory.quantity_of(&"forest_berries"), 0, "the eaten food is consumed")


# --- the choice sub-modal itself (instantiate the panel, drive its methods) ---

func _panel() -> Node:
	var p: Node = PanelScript.new()
	add_child_autofree(p)
	return p


func _is_ascii(s: String) -> bool:
	for i in s.length():
		if s.unicode_at(i) > 127:
			return false
	return true


func test_choice_labels_are_data_driven_and_web_font_safe() -> void:
	var p := _panel()
	await wait_physics_frames(1)
	PlayerData.current_hp = 4  # below full so Eat shows its heal value, not "already full"
	p._open_choice(&"dried_meat", _def(&"dried_meat"))
	assert_true(p._choice_open, "the choice is open")
	assert_string_contains(p._choice_eat_btn.text.to_lower(), "eat")
	assert_string_contains(p._choice_eat_btn.text, "2")          # dried meat heals 2 hearts
	assert_string_contains(p._choice_feed_btn.text, "Briar")     # name from companion_id
	assert_string_contains(p._choice_feed_btn.text, "8")         # bond_delta
	assert_true(_is_ascii(p._choice_eat_btn.text), "eat label has no non-ASCII glyph")
	assert_true(_is_ascii(p._choice_feed_btn.text), "feed label has no non-ASCII glyph")


func test_choice_give_button_feeds_and_consumes() -> void:
	var p := _panel()
	await wait_physics_frames(1)
	Inventory.add(&"dried_meat")
	var before := _bond(&"briar")
	p._open_choice(&"dried_meat", _def(&"dried_meat"))
	p._choose_feed()
	assert_false(p._choice_open, "the modal dismisses after a pick")
	assert_eq(_bond(&"briar"), before + 8.0, "Give fed Briar (+8 bond)")
	assert_eq(Inventory.quantity_of(&"dried_meat"), 0, "the given item is consumed")


func test_cancelling_the_choice_consumes_nothing() -> void:
	var p := _panel()
	await wait_physics_frames(1)
	Inventory.add(&"forest_berries")
	var before := _bond(&"briar")
	p._open_choice(&"forest_berries", _def(&"forest_berries"))
	p._close_choice()
	assert_false(p._choice_open, "cancel closes the modal")
	assert_eq(Inventory.quantity_of(&"forest_berries"), 1, "cancel consumes nothing")
	assert_eq(_bond(&"briar"), before, "cancel feeds nothing")


func test_at_full_health_eat_is_disabled_but_give_still_feeds() -> void:
	var p := _panel()
	await wait_physics_frames(1)
	PlayerData.current_hp = PlayerData.max_hp  # full — eating would be a wasted no-op
	Inventory.add(&"dried_meat")
	var before := _bond(&"briar")
	p._open_choice(&"dried_meat", _def(&"dried_meat"))
	assert_true(p._choice_eat_btn.disabled, "Eat is disabled at full health (no dead default)")
	p._choose_feed()
	assert_eq(_bond(&"briar"), before + 8.0, "Give still feeds at full health")


func test_opening_the_choice_makes_bag_slots_unfocusable() -> void:
	# captive modal: keyboard/gamepad focus must not be able to reach a bag slot behind it
	var p := _panel()
	await wait_physics_frames(1)
	p._open_choice(&"dried_meat", _def(&"dried_meat"))
	for s in p._slots:
		assert_eq(s.focus_mode, Control.FOCUS_NONE, "slots can't take focus while choosing")
	p._close_choice()
	for s in p._slots:
		assert_eq(s.focus_mode, Control.FOCUS_ALL, "slots are focusable again after")


func test_food_affordance_names_any_companion_dynamically() -> void:
	# prove the name is data-driven (a future Echo food), not coincidentally "Briar"
	var d := ItemDef.new()
	d.heal_hearts = 1
	d.use_kind = ItemDef.UseKind.FEED_COMPANION
	d.companion_id = &"echo"
	assert_string_contains(PanelScript.food_affordance(d), "Echo")
