---
name: 2026-06-28-hollow-key-real-find
date: 2026-06-28
tags: [session, level-design, hollow-house, key-gate, legibility]
---

# 2026-06-28 — Make the hollow-house key a real find

Playtest report: the InnerDoor "opens after rattling twice" with no apparent key.
Diagnosed earlier (not a bug): the buried key sat at **(40, 116)**, only **12px**
from the InnerDoor at (48, 125) — inside the player's 48px companion-assist range —
so interacting at the door also dug up the key. The locked-rattle + the dig fired in
the same spot, so finding the key was invisible.

## Change
Moved `BuriedKey` in `scenes/zones/hollow_house.tscn` from **(40, 116)** to
**(-40, 50)** — the open centre of the same bottom-left room (the room that holds
both the spawn and the InnerDoor, below the y=15 HWall, left of the x=60 VWall).

Now:
- Key is **116px** from the door (was 12) — well outside the 48px assist range, so
  interacting at the door no longer auto-digs it.
- Key is **100px** from the spawn — a real walk: you explore, find the fresh-turned
  earth mid-room, dig it (Briar or the no-Briar fallback), *then* cross to the door
  and it opens. Two distinct steps.
- Stays inside the hollow house (user's ask), in open floor, clear of furniture and
  walls, visible (its own dig marker).

## Verified (runtime MCP server, hollow_house.tscn)
- key↔door distance 115.6px (separated_ok); key↔spawn 100px.
- Door starts locked, no key in bag. Digging the key grants `hollow_key` and the
  door unlocks. Screenshot confirms the dig marker sits in open floor, separated
  from the door marker.
- 388/388 tests green (test_hollow_house only asserts the nodes exist, not positions).
