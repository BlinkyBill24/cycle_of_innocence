---
name: Reversible placeholder mode + debug overlay (nav playtest build)
date: 2026-06-20
branch: feature/placeholder-mode
tags: [session, debug, tooling, navigation, placeholder]
---

# 2026-06-20 — Placeholder mode + debug overlay

## What I did
Added a reversible, additive "placeholder mode" so navigation/signposting can be
playtested with art stripped to flat shapes. Quest untouched (reused as-is).

- **`PlaceholderKit`** (`scripts/debug/placeholder_kit.gd`) — the convention in
  one place: shape+colour per category (player=cyan diamond, companion=amber
  octagon, interactable=green square, monster=red triangle, prop=grey square,
  backdrop=slate rect). Vector Polygon2D (Web/Compatibility-safe).
- **`PlaceholderMode`** autoload — default ON (const + `debug/placeholder_mode`
  ProjectSettings override). On `ZoneManager.zone_changed` it walks the live
  scene and, by the existing **groups** (player/companion/enemy, diggable/
  interior_door/searchable), **hides** the original Sprite2D/AnimatedSprite2D and
  adds a flat stand-in child/sibling. Backdrop → flat ground; loose props →
  grey markers. **Fully reversible** (`set_enabled`/`_restore`): originals are
  only hidden, never modified or deleted; nothing on disk is touched. Audio,
  collision, y-sort, behaviour all untouched — visual-only (no collision nodes
  created).
- **`DebugOverlay`** autoload (separate CanvasLayer, layer 128) — **DEFAULT OFF**,
  toggled with **F3**. Shows zone / player coords / last gameplay trigger /
  Dread + Hollowing state. Read-only; the only on-screen text the build adds.
- Registered both autoloads after the existing ones (deps satisfied).
- **Tests** `tests/test_placeholder_mode.gd` (5): convention distinctness,
  skin hides+adds / restore reverses, interactable stand-in, skin→restore→skin
  no-duplicate, and the load-bearing **toggle-invariance** (dig/unlock/journal/
  save identical ON vs OFF). **Suite 280 green with placeholder mode ON _and_
  OFF** (OFF verified via a throwaway `override.cfg`); check-brain green.

## Deliverable 3 — playable-path verification (agents are runtime-blind → static + logic)
- **Quest loop reachable & works under placeholder mode**: spawn
  `playground_fringes` (-300,-180) → **west** edge `VillageTransition` →
  `village_green` → `HollowHouseDoor` (BldCotR) → `hollow_house` → dig `hollow_key`
  → unlock inner door (key consumed) → nook → read ledger → Journal LORE +
  recontext → exit. Logic is covered by GUT (toggle-invariance + the hollow_house
  suite). Placeholder mode adds no collision, so traversal is identical to real art.
- **Fringes traversable / clues / monster reachable**: `playground_fringes`
  keeps `DiggableSpotPlayground` + the whisper clues; the **combat monster**
  (`TwistedChild`) lives in the adjacent **`fringes`** zone (east, reachable via
  `FringesTransition`) — `playground_fringes` itself only has the atmospheric
  `GlimpseSilhouette`. Nothing is walled off (visual-only).

## Deliverable 3.1 — "house dominant from spawn" (resolved)
First pass shipped the build with the spawn (`playground_fringes`) a zone away
from the Hollow House (`village_green`) — so the house was NOT the dominant
feature from spawn. Resolved per the Stop-hook requirement with the smallest
faithful, reversible change (spatial layout only, no UI nudge):
- **Boot the test build into `village_green`** (`project.godot run/main_scene`,
  was `playground_fringes`).
- **Spawn the player at `(360, 60)`** — directly **north of and facing** the
  Hollow House door `(360, 205)`, ~145px ahead — so the house (its green
  interactable stand-in under placeholder mode) is the dominant feature straight
  ahead from spawn. Briar moved alongside to `(335, 82)`.
- **Fringes still reachable**: `village_green` → `PlaygroundTransition` (east) →
  `playground_fringes` (clues) → `FringesTransition` → `fringes` (the
  `TwistedChild` encounter). Nothing walled off.
- **Reversibility**: both are plain test-build settings — revert `main_scene` to
  `playground_fringes` (and the spawn) to restore the normal intro/naming flow.
- Suite still 280 green; the boot now also surfaces the pre-existing
  `village_green.gd` `Ground`/`DuskTint` null refs (logged in ideas) — non-fatal.

## Notes
- `AgeMorph` could in principle re-show the player sprite it toggles; acceptable
  for a throwaway nav build (placeholder still overlays). Flagged for awareness.
- Overlay is dev-only (default-off + explicit F3); remove the two debug autoloads
  before any real release.
