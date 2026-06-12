---
tester: 02 (MR)
date: 2026-06-12
profile: horror-familiar | rpg-familiar
build: fd5d8c8 / 2026-06-12 — NATIVE editor play, not web
session_length: short (crashed-out before village; clock/doom probes n/a)
---
## Observation notes
(none — informal session)
## Debrief answers
1a: 5/5 dog is cute | 1b: 2/5 when you walk to the right and the music
    shifts for the first time | 1c: 3/5 it follows but does not do much else
    (bark sometimes)
2: neither | doom: 1/10, evidence: none *(n/a — never reached the village)*
3: **broken** — soothing was not clear; there WAS a progress bar when
   holding E (tester-01 fix working) but the hint text was hidden behind
   the hearts
4: "beginning very good, fits the atmosphere" | overlap: reggae sounding
   music when darkness/terror starts is unfitting
5: 3/5 dark and a little bit unsettling; reggae music breaks the immersion
6: **no** — the game crashed when walking left to the village
## One surprise
"Crash" was the editor pausing on resource errors: village_tileset.tres
declared 4 dirt-variant tiles but the curated texture has ONE — three
out-of-texture tiles errored exactly when the village scene loaded (the
moment of walking left). Root-caused and fixed same day.
