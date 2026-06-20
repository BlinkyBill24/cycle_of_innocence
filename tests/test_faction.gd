extends GutTest
## Faction.hostile truth table (combat.md): player+ally are one side, enemy the
## other; a hit lands only across the line, never on your own side.

func test_enemy_is_hostile_to_player_and_ally() -> void:
	assert_true(Faction.hostile(Faction.ENEMY, Faction.PLAYER), "enemy hits player")
	assert_true(Faction.hostile(Faction.PLAYER, Faction.ENEMY), "player hits enemy")
	assert_true(Faction.hostile(Faction.ENEMY, Faction.ALLY), "enemy hits ally")
	assert_true(Faction.hostile(Faction.ALLY, Faction.ENEMY), "ally (thrall) hits enemy")


func test_same_side_never_friendly_fires() -> void:
	assert_false(Faction.hostile(Faction.ALLY, Faction.PLAYER), "thrall never hits Rowan")
	assert_false(Faction.hostile(Faction.PLAYER, Faction.ALLY), "Rowan's own side is safe")
	assert_false(Faction.hostile(Faction.PLAYER, Faction.PLAYER))
	assert_false(Faction.hostile(Faction.ENEMY, Faction.ENEMY), "monsters don't friendly-fire")
	assert_false(Faction.hostile(Faction.ALLY, Faction.ALLY))
