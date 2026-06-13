class_name InteriorRoot
extends ZoneRoot
## A single interior FLOOR — cottage ground, basement, cave level, attic
## (accessible-interiors). Inherits ZoneRoot's camera-clamp-per-GroundBackdrop
## invariant and spawn placement unchanged: each floor is its own scene with its
## own backdrop, so the clamp just works. Recontext (`recontext_<id>` /
## `recontext_stage_<n>`) and VillageState (`marker_<name>`) groups also work
## untouched — they key on groups at zone enter.
##
## Adds only a per-floor dread baseline: a cellar/cave raises the dread floor;
## a tended home leaves it at 0 so dread decays (the inside↔outside contrast is
## the point). Darkness (ambient PointLight2D + LightOccluder2D walls) is
## authored in the scene, not here.

## Dread floor while on this floor. > 0 = a dread space (cellar, cave, attic);
## 0 = neutral/safe (dread decays, like stepping into shelter).
@export var dread_baseline: float = 0.0


func _ready() -> void:
	super._ready()  # path record + enter_zone + place_player + camera clamp
	if dread_baseline > 0.0:
		DreadManager.register_zone_level(zone_id, dread_baseline)
		GameEvents.dread_zone_entered.emit(zone_id)


func _exit_tree() -> void:
	# leaving the floor (transition out / reload) drops its dread floor so it
	# doesn't leak into the world or the next floor.
	if dread_baseline > 0.0:
		GameEvents.dread_zone_exited.emit(zone_id)
