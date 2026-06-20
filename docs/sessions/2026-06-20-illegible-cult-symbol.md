---
name: Illegible cult symbol (secret #2)
date: 2026-06-20
branch: feature/illegible-cult-symbol
tags: [session, secrets, recontext, perception, content-complete, playground]
---

# 2026-06-20 — Illegible cult symbol (content-complete, item 2)

## What I did
Authored the playground's **secret #2**: one prominent symbol prop you can't read
yet, gated by `symbol_literacy` via the existing `ZoneRecontext` rail (no new mechanic).
- **CultSymbol** (Sprite2D, reusing the already-declared `totem_bear` art) — the
  visible prop, prominent on the central path.
- **CultSymbolIllegible** WhisperSpot, group `recontext_not_symbol_literacy` —
  the first-read line, live by default.
- **CultSymbolLegible** WhisperSpot, group `recontext_symbol_literacy` — the
  meaning, live only once `revelation_symbol_literacy` is known; records a LORE
  journal entry.

## ⚠ Placeholder strings (yours to write)
The whisper/journal lines are clearly-marked **`TODO(lore):`** placeholders so the
build stays green — the *creative* sigil text is bible lore for you to supply. I did
**not** author a source for `symbol_literacy`; learning to read the marks is a
future content hook (some elsewhere reveal), kept out of scope on purpose.

## Tests
`test_zone_recontext.gd::test_cult_symbol_illegible_until_literacy_learned`:
illegible read live + legible disabled by default; unlocking `symbol_literacy`
swaps them live. Suite **298 green**; check-brain green.
