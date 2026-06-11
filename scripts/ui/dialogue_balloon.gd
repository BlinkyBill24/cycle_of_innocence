class_name GameDialogueBalloon
extends DialogueManagerExampleBalloon
## Project-owned compact balloon (scenes/ui/dialogue_balloon.tscn) — smaller
## box + font than the addon example (playtest 2026-06-11: example took half
## the screen). Choices render INSIDE the box, FF7-style (playtest feedback);
## the box grows taller only while choices are on screen.

const BOX_TOP_PLAIN := -118.0
const BOX_TOP_CHOICES := -196.0

@onready var balloon_margin: MarginContainer = %BalloonMargin


func apply_dialogue_line() -> void:
	balloon_margin.offset_top = BOX_TOP_CHOICES \
			if dialogue_line.responses.size() > 0 else BOX_TOP_PLAIN
	super()
