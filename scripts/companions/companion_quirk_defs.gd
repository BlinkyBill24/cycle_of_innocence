class_name CompanionQuirkDefs
extends RefCounted
## AUTHORED quirk catalogue (docs/mechanics/companion-quirks.md). These are
## designer-scripted progressions on three fixed characters — hand-defined
## thresholds and behaviors, never procedural NPC evolution/hierarchies/ranks
## (patent posture: docs/decisions/2026-06-10-patent-risk-review.md).
##
## truth: 1.0 = the behavior carries real information; 0.0 = it lies.
## High corruption makes reading your family unreliable — that is the horror.

const DEFS := {
	&"briar_scent_growl": {
		"companion": &"briar", "stat": &"bond", "threshold": 60.0, "truth": 1.0,
		# growls at "empty" corners that hide buried things — learn to trust it
	},
	&"briar_long_stare": {
		"companion": &"briar", "stat": &"corruption", "threshold": 40.0, "truth": 1.0,
		# stares a beat too long when given orders; softens to a head-bump
		# once bond is earned (care changes behavior visibly, never removes)
	},
	&"briar_phantom_guard": {
		"companion": &"briar", "stat": &"corruption", "threshold": 70.0, "truth": 0.0,
		# "guards" things that aren't there — indistinguishable from the
		# scent growl unless Empath insight shows the tell
	},
	&"briar_dusk_press": {
		"companion": &"briar", "stat": &"bond", "threshold": 75.0, "truth": 1.0,
		# presses against Rowan's legs as the dark comes; the family holds
	},
}


static func quirks_for(companion_id: StringName) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in DEFS:
		var def: Dictionary = DEFS[id]
		if def.companion == companion_id:
			out.append(id)
	return out


## Acquisition rule: a quirk is earned the moment its stat crosses the
## authored threshold (and never leaves — care softens expression instead).
static func newly_acquired(companion_id: StringName, stat: StringName,
		value: float, owned: Array) -> Array[StringName]:
	var out: Array[StringName] = []
	for id: StringName in DEFS:
		var def: Dictionary = DEFS[id]
		if def.companion == companion_id and def.stat == stat \
				and value >= float(def.threshold) and id not in owned:
			out.append(id)
	return out
