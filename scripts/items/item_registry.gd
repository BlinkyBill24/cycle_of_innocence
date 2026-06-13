class_name ItemRegistry
extends Node
## Stateless, cached catalogue of ItemDef resources. Read-only by contract:
## defs never mutate, so the cache safely survives PlayerData.reset_to_defaults().
## Registered as an autoload so it is reachable as a singleton, but every method
## is static and the class_name makes it callable without the node.

const ITEMS_DIR := "res://resources/items/"

static var _cache: Dictionary = {}


## Cached load of res://resources/items/<id>.tres. push_warning + null on miss.
static func get_def(id: StringName) -> ItemDef:
	if id.is_empty():
		return null
	if _cache.has(id):
		return _cache[id]
	var path: String = ITEMS_DIR + "%s.tres" % String(id)
	if not ResourceLoader.exists(path):
		push_warning("ItemRegistry.get_def: no item resource for id '%s' (%s)" % [id, path])
		return null
	var res: Resource = load(path)
	var def: ItemDef = res as ItemDef
	if def == null:
		push_warning("ItemRegistry.get_def: '%s' is not an ItemDef" % path)
		return null
	_cache[id] = def
	return def


static func has_def(id: StringName) -> bool:
	return get_def(id) != null


## DirAccess scan of resources/items/ — for tests / future tooling.
static func all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	var dir: DirAccess = DirAccess.open(ITEMS_DIR)
	if dir == null:
		return ids
	dir.list_dir_begin()
	var name: String = dir.get_next()
	while name != "":
		if not dir.current_is_dir():
			# Godot exports .tres as .tres.remap / .res in some builds.
			var stem: String = name.get_basename()
			if name.get_extension() == "tres" or name.ends_with(".tres.remap"):
				if name.ends_with(".tres.remap"):
					stem = name.trim_suffix(".tres.remap").get_basename()
				var sid: StringName = StringName(stem)
				if sid not in ids:
					ids.append(sid)
		name = dir.get_next()
	dir.list_dir_end()
	return ids
