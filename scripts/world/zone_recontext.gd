class_name ZoneRecontext
extends Node
## Knowledge-gated world (zone-recontextualization.md): nodes grouped
## `recontext_<revelation_id>` exist only once the revelation is KNOWN;
## `recontext_not_<revelation_id>` only while it is NOT. Applied on zone
## enter and live on revelation unlock — same scene, new truth.

const GROUP_PREFIX := "recontext_"
const NOT_PREFIX := "recontext_not_"


func _ready() -> void:
	GameEvents.revelation_unlocked.connect(func(_id: StringName) -> void: apply())
	apply.call_deferred()


func apply() -> void:
	for node in _recontext_nodes():
		_apply_node(node)


func _recontext_nodes() -> Array:
	var seen := {}
	var out: Array = []
	for group in _recontext_groups():
		for node in get_tree().get_nodes_in_group(group):
			if not seen.has(node):
				seen[node] = true
				out.append(node)
	return out


func _recontext_groups() -> Array:
	# group names aren't globally enumerable cheaply; walk the zone subtree
	var groups := {}
	var stack: Array = [get_parent()]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for group in node.get_groups():
			var name := String(group)
			if name.begins_with(GROUP_PREFIX):
				groups[name] = true
		stack.append_array(node.get_children())
	return groups.keys()


func _apply_node(node: Node) -> void:
	var active := true
	for group in node.get_groups():
		var name := String(group)
		if name.begins_with(NOT_PREFIX):
			active = active and not PlayerData.is_revelation_known(
					StringName(name.trim_prefix(NOT_PREFIX)))
		elif name.begins_with(GROUP_PREFIX):
			active = active and PlayerData.is_revelation_known(
					StringName(name.trim_prefix(GROUP_PREFIX)))
	set_node_active(node, active)


## Visibility + collision + processing in one switch, unit-tested.
static func set_node_active(node: Node, active: bool) -> void:
	if node is CanvasItem:
		(node as CanvasItem).visible = active
	node.process_mode = Node.PROCESS_MODE_INHERIT if active \
			else Node.PROCESS_MODE_DISABLED
	if node is CollisionObject2D:
		for owner_id in (node as CollisionObject2D).get_shape_owners():
			(node as CollisionObject2D).shape_owner_set_disabled(owner_id, not active)
