---
name: Web audio CONFIRMED in-browser
date: 2026-06-20
branch: docs/web-audio-confirmed
tags: [session, web-export, audio, de-risk, slice]
---

# 2026-06-20 — Web build + audio confirmed in a real browser

## The win
Served the exported Web build (`python3 -m http.server` over `exports/web`, port 8081,
`.wasm` served as `application/wasm`) and the human played it in-browser:
**everything works, sounds are audible.**

This closes the **last open Web risk** the recent research flagged. Both Web unknowns are
now proven:
- **LimboAI on Web** — `nothreads` wasm bundles + runs (already confirmed at export).
- **Audio on Web** — the adaptive stems + SFX actually play after the first click. ✅

Why it mattered: browsers block audio until the first user gesture and Web crossfade timing
is looser than in-editor, so "works on F5" never proved Web. `AdaptiveAudio` is DSP-free,
game-clock volume crossfades — the Web-safe pattern — and it held up live.

## Recorded
- [[ideas]] "de-risk Web audio" bullet → **CONFIRMED** (with the re-confirm-after-version-bump caveat).
- [[plan/slice-implementation-roadmap]] Posture callout → Web target now **proven**; the sole
  remaining bottleneck is **content authoring** (recontext lines, companion exchange, horror beat).

## Housekeeping
Stopped the background web server (port 8081 free again). Re-confirm Web audio after any
Godot/addon version bump (templates + addons are pinned to the engine version).
