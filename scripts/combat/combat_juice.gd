class_name CombatJuice
## Small static helpers for combat feel (hitstop now; screenshake later).

static var _hitstop_active := false


static func hitstop(tree: SceneTree, duration: float = 0.07, time_scale: float = 0.05) -> void:
	if tree == null or _hitstop_active:
		return
	_hitstop_active = true
	Engine.time_scale = time_scale
	# Restore via signal callback (not await): the SceneTreeTimer fires on the
	# tree itself, so the restore survives node frees / scene changes.
	# ignore_time_scale = true so the timer runs on real time.
	tree.create_timer(duration, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
		_hitstop_active = false
	)
