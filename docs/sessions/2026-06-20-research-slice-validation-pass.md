---
name: Librarian pass — slice validation/content pass + Web export check
date: 2026-06-20
branch: docs/research-slice-validation-pass
tags: [session, research, librarian, slice, web-export, audio]
---

# 2026-06-20 — Web export audio check + librarian pass (slice validation note)

## Web export + audio check (requested)
Ran a headless **Web export** (`godot --headless --export-release "Web"`): builds clean
(exit 0). Bundle is correct — `index.html/js/wasm`, the 12 MB game `.pck`, audio worklets,
and the **LimboAI `nothreads` wasm** (single-threaded build → no COOP/COEP headers needed,
runs on any plain static host). Payload ~65 MB (47 MB is the standard Godot engine wasm).

**Audio code audit (`AdaptiveAudio`):** Web-safe by design — no AudioEffect/DSP (volume-only
equal-power crossfades), crossfades driven by the game clock (`_process(delta)`, not audio
position, so no desync), and it follows the correct autoplay pattern (Godot 4.x Web suspends
the audio context and resumes on first user gesture; nothing requires sound before a click).
**Unverifiable from here:** whether sound actually plays + crossfades acceptably in a real
browser — that's the human listen (`cd exports/web && python3 -m http.server 8000`).

## Librarian pass — `2026-06-20-vertical-slice-validation-content-pass.md`
~90% already covered by the slice roadmap + the solo-dev-setup note + AGENTS guardrails (the
note even warns against duplicating the live roadmap). **Light integration**: one **"Posture"
callout** in [[plan/slice-implementation-roadmap]] — reframe remaining slice work as
**validation + content, not build**; name the two bottlenecks (Web-proof/audio + content
authoring / "content drought"); keep **Briar**, not Echo/Storm; cross-link both 2026-06-20
research notes.

Resolved/declined: dropped unconfirmable "gdkeys"/Rami Ismail attributions; did NOT re-add the
Web-audio de-risk (already in [[ideas]]); no parallel 0–10 task list (would duplicate M0–M3);
no art-register/backdrop edits (open decisions). Marked `integrated`, moved to `docs/research/done/`.
