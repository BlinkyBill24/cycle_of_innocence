extends Node
## Global signal bus for Cycle of Innocence (decoupled systems: age, morality, companions, horror, dialogue, zones).

signal age_advanced(new_stage: int)
signal morality_changed(new_value: float, delta: float)
signal revelation_unlocked(revelation_id: StringName)

signal companion_bond_changed(companion_id: StringName, bond_value: float)
signal companion_corrupted(companion_id: StringName, level: float)
signal companion_lost(companion_id: StringName, permanent: bool)
signal companion_bark(companion_id: StringName)
signal diggable_revealed(spot_id: StringName)

signal combat_hit(target_faction: StringName, amount: int)
signal player_damaged(current_hp: int, max_hp: int)
signal player_died
signal enemy_died(enemy_kind: StringName)
signal monster_stilled(stable_id: StringName)
signal stilled_monster_killed(stable_id: StringName)

signal horror_stinger(trigger: StringName)  # e.g. "first_revelation", "animal_fear"
signal dread_zone_entered(zone_id: StringName)
signal dread_zone_exited(zone_id: StringName)

signal exploration_paused
signal exploration_resumed

signal cutscene_started(id: StringName)
signal cutscene_finished(id: StringName)
