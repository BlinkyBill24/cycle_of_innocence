extends GutTest
## Throw-at-NPC reaction (ONE showcase NPC, Marta): a thrown object provokes a
## scripted, STATE-KEYED reaction — never adaptive/learning/pursuing. The line
## branches on the NPC's CURRENT state; the hit raises village suspicion.

const ReactionScript := preload("res://scripts/npcs/npc_throw_reaction.gd")
const REACTION_DIALOGUE := "res://resources/dialogue/marta_throw_reaction.dialogue"


func before_each() -> void:
	PlayerData.reset_to_defaults()
	VillageState.reset()
	HollowingClock.reset()


func after_each() -> void:
	PlayerData.reset_to_defaults()
	VillageState.reset()
	HollowingClock.reset()


func _reaction() -> NpcThrowReaction:
	var r: NpcThrowReaction = ReactionScript.new()
	r.npc_id = &"marta_farmer"
	add_child_autofree(r)
	return r


func _thrown_area() -> Area2D:
	var a := Area2D.new()
	a.add_to_group("thrown")
	add_child_autofree(a)
	return a


# --- a thrown hit fires a reaction ----------------------------------------

func test_thrown_object_fires_a_reaction() -> void:
	var r := _reaction()
	await wait_physics_frames(1)
	watch_signals(GameEvents)
	r._on_area_entered(_thrown_area())
	assert_signal_emitted(GameEvents, "npc_reacted_to_throw", "a thrown hit provokes the NPC")


func test_a_melee_swing_is_not_a_thrown_hit() -> void:
	# an area that is NOT in group "thrown" (e.g. the player's melee hitbox) must not provoke
	var r := _reaction()
	await wait_physics_frames(1)
	var melee := Area2D.new()  # no "thrown" group
	add_child_autofree(melee)
	watch_signals(GameEvents)
	r._on_area_entered(melee)
	assert_signal_not_emitted(GameEvents, "npc_reacted_to_throw", "only THROWN objects provoke")


# --- the line varies by CURRENT state (not history) -----------------------

func test_reaction_title_varies_by_state() -> void:
	assert_eq(ReactionScript.choose_reaction_title(0, 0.0), &"calm", "early + unsuspicious = calm")
	assert_eq(ReactionScript.choose_reaction_title(1, 0.0), &"wary", "the clock turning = wary")
	assert_eq(ReactionScript.choose_reaction_title(2, 0.0), &"afraid", "net closing = afraid")
	assert_eq(ReactionScript.choose_reaction_title(0, 80.0), &"afraid", "high suspicion = afraid even at stage 0")
	assert_ne(ReactionScript.choose_reaction_title(0, 0.0),
		ReactionScript.choose_reaction_title(2, 0.0), "the reaction differs across states")


func test_authored_variants_have_distinct_lines() -> void:
	var res: DialogueResource = load(REACTION_DIALOGUE)
	assert_not_null(res, "Marta's reaction dialogue loads")
	var calm: DialogueLine = await DialogueManager.get_next_dialogue_line(res, "calm")
	var afraid: DialogueLine = await DialogueManager.get_next_dialogue_line(res, "afraid")
	assert_ne(calm.text, afraid.text, "calm and afraid are different authored lines")


# --- the hit raises suspicion, and it persists ----------------------------

func test_hit_raises_suspicion_and_persists_across_save_load() -> void:
	assert_eq(VillageState.get_suspicion(&"marta_farmer"), 0.0, "clean to start")
	var r := _reaction()
	r.react()
	var after := VillageState.get_suspicion(&"marta_farmer")
	assert_gt(after, 0.0, "a provocation is noticed — suspicion rises")

	assert_true(SaveManager.save_game(96), "save writes")
	VillageState.reset()
	assert_eq(VillageState.get_suspicion(&"marta_farmer"), 0.0, "scrambled")
	assert_true(SaveManager.load_game(96, false), "load reads")
	assert_almost_eq(VillageState.get_suspicion(&"marta_farmer"), after, 0.01,
		"the raised suspicion survives save/load")
	SaveManager.delete_save(96)


func test_hit_hardens_rowan_a_touch() -> void:
	var m0 := PlayerData.morality
	var r := _reaction()
	r.react()
	assert_gt(PlayerData.morality, m0, "striking a person nudges morality toward Vessel")


# --- regression: other NPCs are non-reactive ------------------------------

func test_a_plain_villager_has_no_reaction_component() -> void:
	# the base villager PREFAB is non-reactive; reactivity is opt-in per placed instance
	var villager: Node = load("res://scenes/npcs/villager.tscn").instantiate()
	add_child_autofree(villager)
	await wait_physics_frames(1)
	var reactions := villager.find_children("*", "NpcThrowReaction", true, false)
	assert_eq(reactions.size(), 0, "a plain villager prefab carries no reaction by default")


# --- scaled rollout: each authored NPC has its OWN reaction ----------------

func test_each_authored_npc_has_distinct_reaction_lines() -> void:
	var dialogues := [
		"res://resources/dialogue/marta_throw_reaction.dialogue",
		"res://resources/dialogue/pieter_throw_reaction.dialogue",
		"res://resources/dialogue/elder_aldwin_throw_reaction.dialogue",
		"res://resources/dialogue/warden_brek_throw_reaction.dialogue",
		"res://resources/dialogue/lena_throw_reaction.dialogue",
		"res://resources/dialogue/warden_oslo_throw_reaction.dialogue",
	]
	for path: String in dialogues:
		var res: DialogueResource = load(path)
		assert_not_null(res, "%s loads" % path.get_file())
		var calm: DialogueLine = await DialogueManager.get_next_dialogue_line(res, "calm")
		var afraid: DialogueLine = await DialogueManager.get_next_dialogue_line(res, "afraid")
		assert_ne(calm.text, afraid.text, "%s: calm and afraid are distinct" % path.get_file())


func test_village_rolls_reactions_out_to_several_npcs() -> void:
	var zone: Node = load("res://scenes/zones/village_green.tscn").instantiate()
	add_child_autofree(zone)
	await wait_physics_frames(1)
	var reactions := zone.find_children("*", "NpcThrowReaction", true, false)
	assert_true(reactions.size() >= 5, "the reaction is rolled out to several village NPCs")
	# each reactive NPC points at its OWN authored lines (specific to who they are)
	var paths := {}
	for r in reactions:
		paths[(r as NpcThrowReaction).reaction_dialogue_path] = true
	assert_true(paths.size() >= 5, "each reactive NPC has a distinct authored reaction")
