extends Node
## Journal of observed signs (docs/design/secrets-and-discovery.md +
## docs/mechanics/progression.md). The Outer-Wilds ship-log / Obra-Dinn line:
## a memory aid for things the player has WITNESSED, never a quest log or
## checklist. Entries appear ONLY when gameplay calls witness() in response to
## a world change the player actually saw — there are no pending/to-do entries.
##
## Two kinds of sign (the same store, distinguished by `kind`):
##  - "lore"  : secrets pillar — a dug keepsake, a Stilled monster's keepsake
##  - "doom"  : hollowing-clock doom-legibility — an observed sign of the net
##              closing ("The Wardens carry lanterns now")
## Saved per-slot via SaveManager. NG+ may pre-seed dread-tinged entries via
## the `knew_it_was_coming` flag (hook reserved; not auto-populated here).

enum Kind { LORE, DOOM }

## Ordered list of entry dicts: {id: StringName, text: String, kind: int}.
## Insertion order = discovery order (newest appended).
var _entries: Array[Dictionary] = []
var _seen: Dictionary = {}  # sign_id -> true, for O(1) idempotency


## Record a witnessed sign. Idempotent: witnessing the same id twice is a
## no-op (returns false), so re-entering a zone never duplicates an entry.
## Returns true only on the first witnessing (callers may key cues off this).
func witness(sign_id: StringName, text: String, kind: int = Kind.LORE) -> bool:
	if sign_id == &"" or text.is_empty():
		push_warning("Journal.witness: empty id or text")
		return false
	if _seen.has(sign_id):
		return false
	_seen[sign_id] = true
	_entries.append({"id": sign_id, "text": text, "kind": kind})
	if GameEvents:
		GameEvents.journal_entry_added.emit(sign_id)
	return true


func has_entry(sign_id: StringName) -> bool:
	return _seen.has(sign_id)


func entry_count() -> int:
	return _entries.size()


## Newest-first copy for display (the menu reads recent observations on top).
func entries_newest_first() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for i in range(_entries.size() - 1, -1, -1):
		out.append((_entries[i] as Dictionary).duplicate())
	return out


func entries_of_kind(kind: int) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for e: Dictionary in _entries:
		if int(e["kind"]) == kind:
			out.append(e.duplicate())
	return out


func reset() -> void:
	_entries.clear()
	_seen.clear()


func get_save_data() -> Dictionary:
	# store a plain copy; StringName ids serialize as strings in JSON
	var rows: Array = []
	for e: Dictionary in _entries:
		rows.append({"id": String(e["id"]), "text": e["text"], "kind": int(e["kind"])})
	return {"entries": rows}


func apply_save_data(data: Dictionary) -> void:
	reset()
	var rows: Array = data.get("entries", [])
	for row: Variant in rows:
		if row is Dictionary:
			var r := row as Dictionary
			var id := StringName(str(r.get("id", "")))
			var text := str(r.get("text", ""))
			var kind := int(r.get("kind", Kind.LORE))
			if id != &"" and not text.is_empty() and not _seen.has(id):
				_seen[id] = true
				_entries.append({"id": id, "text": text, "kind": kind})
