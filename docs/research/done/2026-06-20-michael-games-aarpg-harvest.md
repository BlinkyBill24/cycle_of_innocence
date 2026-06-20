---
name: michael-games-aarpg-harvest
date: 2026-06-20
source: Claude research run (web) — assessment artifact "Michael Games AARPG Godot 4 Tutorial Series: Compatibility Assessment for Cycle of Innocence"
prompt: "Harvest the 'worth harvesting' findings from the Michael Games AARPG tutorial assessment into a vault input file."
status: integrated
integrated: 2026-06-20 (branch docs/research-aarpg-harvest) — placeholder-only ruling; see integration log at foot
---

# Michael Games AARPG — Harvest Candidates

Scope note: this file carries **only the additive findings** (things to pull into the project). The renderer / save / audio / enemy-AI findings from the source research were *confirmations of existing decisions* ("what not to lift"), not harvest, and are intentionally omitted here — they live in the assessment artifact if needed. Three candidates below, each filtered and mapped.

---

## 1. Free asset pack — **placeholder / greybox use only**

**What it is.** A hand-made, CC-friendly pixel-art top-down ARPG asset pack: player/slime/goblin sprites, dungeon tiles, NPC/dialogue, quest, equipment, boss, shopkeeper, ability, and title-screen art, plus `.wav` SFX and example music.
`michaelgames.itch.io/2d-action-adventure-rpg-assets` [verified 2026-06-20]
License: "name your own price," **free for commercial use, credit welcome**, explicitly "No generative AI was used." [verified 2026-06-20]

**Filter result: PASS — but narrowly, for replay/iteration-velocity, not for the shipped game.**
It does not directly serve story, a companion arc, or a horror beat. It serves *production velocity*: faster prototyping and placeholder-swap builds, which indirectly serve all four by letting slices get tested sooner.

**⚠ Tension with locked pipeline — file as PLACEHOLDER ONLY.**
Locked canon is PixelLab as the single canonical generator for shippable pixel assets, low-top-down projection (Rule 5 / Projection Canon, `CANON_VIEW`), and the master-palette clamp. This pack is hand-drawn with its **own palette and own projection** and would violate both if routed toward final art. Therefore:
- **Permitted use:** placeholder/greybox art for prototype and test builds — including the placeholder-mode test build (flat-color swap, debug-overlay round). A real drawn sprite is sometimes a more honest greybox than a polygon when you need to read silhouette/scale.
- **Prohibited use:** any shippable asset. Do not let pack art reach a release build. If it ever appears in a shipping scene, that's a Projection-Canon + palette-lock violation.
- **Recommendation:** if adopted, drop under a clearly-quarantined `placeholder/` path so the lint/gate can distinguish it from PixelLab output, and so it can't silently survive into ship.

**Maps onto:** the placeholder-mode autoload (already built) as an alternate greybox source; no system change required.

---

## 2. Aseprite as the hand-pipeline cue

**What it is.** The series creator (Michael Malaska) states he authors all sprites in **Aseprite**. [verified 2026-06-20 — creator's own description]

**Filter result: NEUTRAL — informational, not a recommendation to adopt.**
Flagging rather than recommending. Your shippable pipeline is PixelLab-canonical; Aseprite is not currently in the stack and adopting it would be a pipeline decision, not a harvest. The single transferable point: **if** you ever need a hand-edit/cleanup step on a generated sprite (fixing a PixelLab frame, hand-tuning a placeholder, authoring a one-off), Aseprite is the community-standard tool and integrates with a Godot pixel workflow. No action implied; recorded so the option is on the table if a hand-edit need arises.

**Maps onto:** nothing currently. Pure optionality note. Do not treat as a stack change unless explicitly reopened.

---

## 3. MIT reference repo — **read-only typed-combat reference**

**What it is.** Full project source, MIT-licensed, GDScript 100%, modern Godot 4.x.
`github.com/michaelmalaska/aarpg-tutorial` [verified 2026-06-20 — live GitHub page]
Confirmed idioms in-repo: callable-based signals (`hit_box.damaged.connect(_take_damage)`), `.emit()` syntax, `TileMapLayer`, consistent static typing (typed `@export`, typed `@onready` node refs, typed signatures/returns, `class_name` types used as static types). [verified 2026-06-20 — `enemy.gd` read directly]

**Filter result: PASS (replay/quality, indirect) — as a reference only, with one hard exclusion.**
Value is code-quality reference for your mercy/soothe combat verbs: a clean, idiomatic, typed Godot-4 hit/hurt-box (Area2D overlap) implementation is a useful comparison point if you ever revisit combat plumbing. Serves the game only indirectly (better/cleaner combat code → more reliable horror beats in encounters).

**⚠ Two hard exclusions — do NOT lift wholesale.**
- **Signal style:** the repo calls autoload singletons **directly by name** (e.g. `PlayerManager.shake_camera()`, `EffectManager.damage_text(...)`) and has **no central signal bus**. Your **GameEvents bus is the more-decoupled, better pattern for this project — keep it.** Adopting the repo's direct-call style would be a regression. Read the repo for *typed combat shape*, not for *wiring philosophy*.
- **Enemy AI:** the repo uses a **hand-rolled GDScript FSM**, not LimboAI (the repo's `blackboard.tscn` is an unrelated in-editor to-do board, NOT a LimboAI Blackboard — do not mistake it for behavior-tree usage). You are standardized on **LimboAI**; this repo offers **no transferable AI patterns**. Ignore its enemy-behavior structure entirely.

**Maps onto:** mercy/soothe combat (read-only reference for the typed Area2D hit/hurt-box layer). Explicitly does **not** map onto GameEvents (keep yours) or companion/enemy behavior (stay on LimboAI).

---

## Net recommendation

Harvest **one thing actively, two as recorded options.**
- **Active:** adopt the asset pack as a **quarantined placeholder source** for prototype/test builds (candidate #1), under a `placeholder/`-style path the gate can isolate. This is the only item with an immediate use, and it pairs with the placeholder-mode build already on main.
- **Recorded option:** Aseprite (candidate #2) — note only; no stack change unless a hand-edit need arises.
- **Recorded reference:** the MIT repo (candidate #3) — bookmark read-only for typed combat code; do **not** lift signal wiring or AI.

Everything here is additive and conflicts with **zero** locked decisions **provided** the asset pack stays placeholder-only and the repo stays read-only. The two ⚠ flags (palette/projection canon; GameEvents + LimboAI) are the guardrails that keep it that way.

## Open question for triage
- The asset pack's placeholder-vs-shippable boundary is the one judgment that needs an explicit ruling before integration. This file assumes **placeholder-only**. If the intent was ever shippable-art sourcing, that reopens Projection Canon and the palette lock and should be its own decision file, not an inbox integration.

---

## Librarian integration log (2026-06-20, branch `docs/research-aarpg-harvest`)

Processed per `docs/research/README.md` (propose-first). Human ruling: **placeholder-only** boundary for the asset pack; **apply all** additive notes. Zero locked decisions reopened.

- **`docs/design/ai-production-setup.md`** — added a placeholder-asset-pack note under "Installed in this repo": michaelgames.itch.io pack as a **placeholder-only, quarantined** greybox source (under a `placeholder/` path), **prohibited from ship** (Projection Canon + palette lock); pairs with placeholder mode. Aseprite recorded as optionality only (already noted "no Aseprite installed").
- **`docs/mechanics/combat.md`** — Technical Notes: read-only **typed Area2D hit/hurtbox reference** (MIT `aarpg-tutorial`) with the two hard exclusions (keep the GameEvents bus; stay on LimboAI).
- **`docs/ideas.md`** — actionable adopt task (quarantined `placeholder/` asset pack), the MIT-repo combat bookmark, and the Aseprite optionality note.
- **Not done (correctly):** no `placeholder/` dir or lint created yet (premature — created when assets are actually downloaded); no shippable-art adoption (would need its own decision per the open question).
