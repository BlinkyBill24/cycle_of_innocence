---
name: 2026-06-28-readable-ui-text
date: 2026-06-28
tags: [session, ui, rendering, readability]
---

# 2026-06-28 — Smooth/readable UI text (stretch mode)

User: HUD + dialogue text looked pixelated/hard to read.

## Root cause
The game renders the whole frame into a 720×480 buffer (deliberate pixel
pipeline, `display/window/stretch/mode="viewport"`) and nearest-upscales it to
the 1920×1080 window. Text lives *inside* that low-res buffer, so it gets
upscaled blocky along with everything else. There is **no custom UI font** — it's
Godot's default font. In `viewport` mode you can't make one layer (the UI) render
sharper than 720×480, so a per-node texture filter does nothing.

## Fix
`display/window/stretch/mode`: **`viewport` → `canvas_items`** (`project.godot`).
In `canvas_items` the 2D canvas is scaled by a transform and primitives —
including font glyphs — are rasterized at the **full window resolution**, so all
UI text (HUD, dialogue balloon, prompts, toasts, journal) is now smooth and crisp.
Verified live via the runtime MCP server: the captured frame is now full-res
(1560×1040) and the HUD + intro dialogue render smooth; the pixel-art hearts stay
crisp.

## Tradeoff (flagged to the user)
Pixel-art sprites now scale at a non-integer ratio (~2.17×) instead of a uniform
whole-frame upscale, which can cause slight pixel unevenness on detailed sprites
in motion. Simple sprites looked fine in testing. Camera framing is unchanged
(still a 720×480 logical view, zoom 1). Uncovered areas show the window clear
color (grey) rather than black — only visible in undressed graybox rooms.

If the sprite look bothers the team, the fallback is to revert to `viewport` and
render the UI on a separate full-resolution layer (keeps the pixel world exactly,
more involved). Not done unless asked.

## Note
`project.godot` is a protected file — the API merge may phantom-fail and need a
human web-UI merge. 388/388 tests green.
