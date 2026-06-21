class_name Inventory
extends Node
## Stateless inventory verbs. All mutations operate ON PlayerData.inventory
## (each slot a Dictionary {id: StringName, quantity: int}, max MAX_SLOTS) and
## emit via GameEvents. Keeps PlayerData pure progression-state and keeps this
## logic unit-testable without a node (callable statically via class_name).
##
## Definitions live as ItemDef .tres resolved through ItemRegistry.
## Inventory.use NEVER calls DialogueManager — scripted dialogue beats own
## their own deltas (see escape_food.dialogue).

const MAX_SLOTS := 10


## --- mutation ---

## Add `qty` of `id`. Stacks into an existing slot up to ItemDef.max_stack when
## stackable, else opens a new slot. Returns false (and emits item_add_failed)
## on unknown id or when there is no room — never a silent drop.
static func add(id: StringName, qty: int = 1) -> bool:
	if qty <= 0:
		return false
	var def: ItemDef = ItemRegistry.get_def(id)
	if def == null:
		_emit_add_failed(id, &"unknown_item")
		return false

	var inv: Array[Dictionary] = PlayerData.inventory
	var remaining: int = qty

	if def.stackable:
		for slot: Dictionary in inv:
			if slot.get("id") == id:
				var current: int = int(slot.get("quantity", 0))
				var room: int = maxi(0, def.max_stack - current)
				if room <= 0:
					continue
				var moved: int = mini(room, remaining)
				slot["quantity"] = current + moved
				remaining -= moved
				if remaining <= 0:
					break

	while remaining > 0:
		if inv.size() >= MAX_SLOTS:
			_emit_add_failed(id, &"inventory_full")
			# Partial success still counts: anything already placed is real.
			if remaining < qty:
				_emit_changed()
			return false
		var stack: int = remaining if def.stackable else 1
		stack = mini(stack, def.max_stack) if def.stackable else 1
		inv.append({"id": id, "quantity": stack})
		remaining -= stack

	# Acquiring a gate item permanently unlocks its story flag (e.g. flute -> soothing).
	if def.grants_flag != &"":
		PlayerData.set_story_flag(def.grants_flag)
	if GameEvents:
		GameEvents.item_acquired.emit(id, qty)
	_emit_changed()
	return true


## Remove `qty` of `id` from the first matching slot(s). Refuses (false) when
## absent or when the def is non-discardable (Key Items).
static func remove(id: StringName, qty: int = 1) -> bool:
	if qty <= 0:
		return false
	var def: ItemDef = ItemRegistry.get_def(id)
	if def != null and not def.discardable:
		return false
	if not has(id):
		return false
	return _take(id, qty, true)


## Index variant of remove(); same discardable guard.
static func remove_at(slot_index: int, qty: int = 1) -> bool:
	var inv: Array[Dictionary] = PlayerData.inventory
	if slot_index < 0 or slot_index >= inv.size():
		return false
	var id: StringName = inv[slot_index].get("id", &"")
	var def: ItemDef = ItemRegistry.get_def(id)
	if def != null and not def.discardable:
		return false
	return _take_at(slot_index, qty, true)


## Use one `id`: dispatch on def.use_kind. Emits item_used BEFORE consuming so
## listeners can read pre-consume state. Decrements when consumed_on_use.
## NEVER calls DialogueManager.
static func use(id: StringName, target_companion: StringName = &"") -> bool:
	if not has(id):
		return false
	var def: ItemDef = ItemRegistry.get_def(id)
	if def == null:
		return false

	match def.use_kind:
		ItemDef.UseKind.FEED_COMPANION:
			var target: StringName = def.companion_id if not def.companion_id.is_empty() else target_companion
			if target.is_empty():
				push_warning("Inventory.use: FEED_COMPANION '%s' has no target companion" % id)
				return false
			if not is_zero_approx(def.bond_delta):
				PlayerData.add_companion_bond(target, def.bond_delta)
			if not is_zero_approx(def.morality_delta):
				PlayerData.change_morality(def.morality_delta)
		ItemDef.UseKind.EQUIP, ItemDef.UseKind.THROW:
			# "Using" a weapon equips it (tap-to-equip from the satchel). The
			# attack reads the equipped weapon's kind. Reusable — never consumed.
			PlayerData.equipped_weapon = (&"" if PlayerData.equipped_weapon == id else id)
		ItemDef.UseKind.NONE:
			pass

	if GameEvents:
		GameEvents.item_used.emit(id)

	if def.consumed_on_use:
		_take(id, 1, false)  # _take emits inventory_changed when it removes
	else:
		_emit_changed()  # non-consumed use: signal listeners ourselves
	return true


## Eat a food/medicine item: heal Rowan by its `heal_hearts` (HEAL path, decision
## 2026-06-21), then consume ONE. GENERIC — reads heal_hearts, not item ids, so medicine
## reuses it. The heal is applied by the player (via GameEvents.player_heal_requested ->
## Health.heal, which clamps to max). Eating at FULL health does nothing and does NOT
## consume the food (no waste). Returns true only when food was actually eaten.
static func eat(id: StringName) -> bool:
	if not has(id):
		return false
	var def: ItemDef = ItemRegistry.get_def(id)
	if def == null or def.heal_hearts <= 0:
		return false
	if PlayerData.current_hp >= PlayerData.max_hp:
		return false  # already full -> no heal, no waste
	if GameEvents:
		GameEvents.player_heal_requested.emit(def.heal_hearts * PlayerData.HP_PER_HEART)
		GameEvents.item_used.emit(id)
	Sfx.play(&"eat", -5.0)
	_take(id, 1, false)  # consume exactly one
	return true


static func use_at(slot_index: int, target_companion: StringName = &"") -> bool:
	var inv: Array[Dictionary] = PlayerData.inventory
	if slot_index < 0 or slot_index >= inv.size():
		return false
	var id: StringName = inv[slot_index].get("id", &"")
	return use(id, target_companion)


## --- queries ---

static func has(id: StringName) -> bool:
	for slot: Dictionary in PlayerData.inventory:
		if slot.get("id") == id and int(slot.get("quantity", 0)) > 0:
			return true
	return false


## Distinct slots used.
static func count() -> int:
	return PlayerData.inventory.size()


## Total quantity of `id` across all slots, 0 if absent.
static func quantity_of(id: StringName) -> int:
	var total: int = 0
	for slot: Dictionary in PlayerData.inventory:
		if slot.get("id") == id:
			total += int(slot.get("quantity", 0))
	return total


static func is_full() -> bool:
	return count() >= MAX_SLOTS


## Defensive deep copy for UI — never hand out the live array.
static func slots() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for slot: Dictionary in PlayerData.inventory:
		out.append(slot.duplicate(true))
	return out


## Tier-aware inspect text; delegates to ItemDef.read_description().
static func describe(id: StringName) -> String:
	var def: ItemDef = ItemRegistry.get_def(id)
	if def == null:
		return ""
	return def.read_description()


## --- internals ---

## Decrement `qty` of `id` across slots (first-match first), freeing empty
## slots. When `discard` and a removal lands, emit item_discarded.
static func _take(id: StringName, qty: int, discard: bool) -> bool:
	var inv: Array[Dictionary] = PlayerData.inventory
	var remaining: int = qty
	var removed_any: bool = false
	var i: int = 0
	while i < inv.size() and remaining > 0:
		var slot: Dictionary = inv[i]
		if slot.get("id") == id:
			var current: int = int(slot.get("quantity", 0))
			var taken: int = mini(current, remaining)
			remaining -= taken
			removed_any = removed_any or taken > 0
			if current - taken <= 0:
				inv.remove_at(i)
				continue
			else:
				slot["quantity"] = current - taken
		i += 1
	if removed_any:
		if discard and GameEvents:
			GameEvents.item_discarded.emit(id)
		_emit_changed()
	return removed_any


static func _take_at(slot_index: int, qty: int, discard: bool) -> bool:
	var inv: Array[Dictionary] = PlayerData.inventory
	if slot_index < 0 or slot_index >= inv.size():
		return false
	var slot: Dictionary = inv[slot_index]
	var id: StringName = slot.get("id", &"")
	var current: int = int(slot.get("quantity", 0))
	var taken: int = mini(current, qty)
	if taken <= 0:
		return false
	if current - taken <= 0:
		inv.remove_at(slot_index)
	else:
		slot["quantity"] = current - taken
	if discard and GameEvents:
		GameEvents.item_discarded.emit(id)
	_emit_changed()
	return true


static func _emit_add_failed(id: StringName, reason: StringName) -> void:
	if GameEvents:
		GameEvents.item_add_failed.emit(id, reason)


static func _emit_changed() -> void:
	if GameEvents:
		GameEvents.inventory_changed.emit()
