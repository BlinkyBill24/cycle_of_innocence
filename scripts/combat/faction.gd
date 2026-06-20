class_name Faction
extends Object
## Who-hurts-whom for hit/hurtboxes. Three sides share ONE hit_hurt collision
## layer (combat.md) and resolve in code — we do NOT split factions across
## physics layers, so existing hitbox/hurtbox nodes keep their layers untouched.
##
## Rule: the player and their allies are one side; monsters are the other. A hit
## only lands ACROSS the line. So a Dominated thrall (ally) wounds enemies and
## never the player, while enemies still strike the player — and nobody friendly-
## fires their own side (enemy↔enemy, player↔ally). See encounters-mercy.md
## (Domination) for why the Vessel-path thrall needs the ally tag.

const PLAYER := &"player"
const ALLY := &"ally"
const ENEMY := &"enemy"


## True when an attacker of faction `a` should damage a target of faction `b`.
## Pure + symmetric: hostile iff exactly ONE side is the monster faction.
static func hostile(a: StringName, b: StringName) -> bool:
	return (a == ENEMY) != (b == ENEMY)
