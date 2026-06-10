extends Node
## Global signal bus for Cycle of Innocence (decoupled systems: age, morality, companions, horror, dialogue, zones).

signal age_advanced(new_stage: int)
signal morality_changed(new_value: float, delta: float)
signal revelation_unlocked(revelation_id: StringName)

signal companion_bond_changed(companion_id: StringName, bond_value: float)
signal companion_corrupted(companion_id: StringName, level: float)
signal companion_lost(companion_id: StringName, permanent: bool)

signal horror_stinger(trigger: StringName)  # e.g. "first_revelation", "animal_fear"
signal dread_zone_entered(zone_id: StringName)
signal dread_zone_exited(zone_id: StringName)

signal exploration_paused
signal exploration_resumed

signal cutscene_started(id: StringName)
signal cutscene_finished(id: StringName)
