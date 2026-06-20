extends GutTest
## The Journal is a modal reading view — opening it freezes the world like the
## satchel (you shouldn't be chased/hit while reading), with strict pause/resume
## pairing and yielding to a foreign pause (dialogue / the satchel).

var journal: JournalPanel


func before_each() -> void:
	PlayerData.reset_to_defaults()
	journal = JournalPanel.new()
	add_child_autofree(journal)
	await wait_physics_frames(1)


func after_each() -> void:
	GameEvents.exploration_resumed.emit()  # never leave the world paused
	PlayerData.reset_to_defaults()


func test_opening_journal_pauses_and_closing_resumes() -> void:
	watch_signals(GameEvents)
	journal.toggle()  # open
	assert_true(journal.visible, "journal is shown")
	assert_signal_emitted(GameEvents, "exploration_paused", "opening freezes the world")
	journal.toggle()  # close
	assert_false(journal.visible, "journal is hidden")
	assert_signal_emitted(GameEvents, "exploration_resumed", "closing thaws it")


func test_journal_yields_to_a_foreign_pause_without_double_resume() -> void:
	journal.toggle()  # open (emits its own pause)
	assert_true(journal.visible)
	watch_signals(GameEvents)
	# dialogue (or the satchel) pauses the world while the journal is open
	GameEvents.exploration_paused.emit()
	assert_false(journal.visible, "journal yields to the foreign pause")
	# it must NOT emit resume — the foreign pauser owns that
	assert_signal_not_emitted(GameEvents, "exploration_resumed",
		"the journal does not steal the resume it didn't own")
