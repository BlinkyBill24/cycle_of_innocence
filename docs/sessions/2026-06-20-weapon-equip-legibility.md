---
name: Weapon equip legibility (playtest fixes)
date: 2026-06-20
branch: fix/weapon-equip-legibility
tags: [session, combat, inventory, ui, hud, playtest, legibility]
---

# 2026-06-20 — Weapon equip legibility (playtest bug pass)

Three in-browser playtest reports; diagnosed all before touching code.

## 1 + 2 — "items cannot be equipped" / "unclear what I hit with" (FIXED)
**Not a functional bug** — equipping always worked (the green `test_weapon_combat`
proves the stick equips without being consumed). The real problem: **equipping was
invisible** and every attack sounded identical, so the player couldn't tell it had
worked or what they were wielding. Fix (legibility only, no balance change):
- **HUD weapon line** (`hud.gd`): "Bare hands" / "Sturdy Stick" / "Slingshot (N)"
  (throw weapons show ammo). Refreshes on `item_used` (equip) + `inventory_changed` (ammo).
- **Satchel** (`inventory_panel.gd`): the equipped weapon's slot **glows warm**, and the
  detail panel shows **"Tap to equip"** / **"Equipped — tap to put it away"** — the
  tap-to-equip verb was never signposted.
- **Per-weapon swing pitch** (`player_controller.attack_pitch` + new `Sfx.play(base_pitch)`):
  a stick lands lower, the sling whips higher, bare hands sit in the middle — so the three
  read by ear. Asset-free.

## 3 — "sometimes monsters do not fully calm, why?" (WORKING AS DESIGNED — explained)
The generic lullaby **plateaus at Recognition 60**; a monster only fully calms (Stilled)
once you have **its key** — dig up its buried toy with Briar (`soothe_key_flag`,
`dug_playground_buried_toy` for the TwistedChild). The soothe prompt already says
*"it calms… but something is missing"* and the monster glances toward its buried key.
This is the intended mercy mechanic (encounters-mercy.md) — left untouched; balance is the
human's call. *Minor note:* the second fringes monster (`twisted_child_02`, added for the
faction demo) has no `secret_spot_path`, so it shows the verbal stall cue but no glance —
fine for a demo; give it a key/secret if it ever becomes real content.

## Tests — suite 316 green, check-brain green
`test_weapon_feedback.gd`: `weapon_label` (hands/melee/throw+ammo), `weapon_affordance`
(tap-to-equip / equipped / empty for non-weapons), `attack_pitch` (hands<stick? no —
hands=1.0, stick<1.0<sling, all distinct). On-screen label/tint are F5 checks.
