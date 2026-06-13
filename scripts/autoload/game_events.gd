extends Node
## Global signal bus for Cycle of Innocence (decoupled systems: age, morality, companions, horror, dialogue, zones).

signal age_advanced(new_stage: int)
signal morality_changed(new_value: float, delta: float)
signal revelation_unlocked(revelation_id: StringName)

signal companion_bond_changed(companion_id: StringName, bond_value: float)
signal companion_corrupted(companion_id: StringName, level: float)
signal companion_lost(companion_id: StringName, permanent: bool)
signal companion_bark(companion_id: StringName)
signal quirk_acquired(companion_id: StringName, quirk_id: StringName)
signal quirk_expressed(companion_id: StringName, quirk_id: StringName)
signal diggable_revealed(spot_id: StringName)

signal combat_hit(target_faction: StringName, amount: int)
signal player_damaged(current_hp: int, max_hp: int)
signal player_died
signal enemy_died(enemy_kind: StringName)
signal monster_stilled(stable_id: StringName)
signal stilled_monster_killed(stable_id: StringName)
signal monster_dominated(stable_id: StringName)
signal stilled_led_to_secret(stable_id: StringName, spot_id: StringName)

signal horror_stinger(trigger: StringName)  # e.g. "first_revelation", "animal_fear"
signal dread_zone_entered(zone_id: StringName)
signal dread_zone_exited(zone_id: StringName)
signal hollowing_stage_advanced(stage: int)
signal hideout_entered
signal hideout_exited

signal exploration_paused
signal exploration_resumed

signal cutscene_started(id: StringName)
signal cutscene_finished(id: StringName)

signal journal_entry_added(sign_id: StringName)  # observed-sign witnessed (Journal)

signal item_acquired(item_id: StringName, quantity: int)
signal item_used(item_id: StringName)
signal item_discarded(item_id: StringName)
signal item_add_failed(item_id: StringName, reason: StringName)  # reason: &"inventory_full" / &"unknown_item"
signal inventory_changed
