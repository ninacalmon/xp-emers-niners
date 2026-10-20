@tool
extends Node3D

@export var repeat_levels: Array[int] = [1] : set = set_repeat_levels
@export var repeat_offsets: Array[Vector3] = [Vector3(1, 0, 0)] : set = set_repeat_offsets
@export var force_refresh: bool = false : set = set_force_refresh
@export var bake_copies: bool = false : set = set_bake_copies

var _hooks = Dictionary()


func _ready():
	_adjust_copies()


func set_bake_copies(value):
	_bake_copies()

func apply_array_modifier():
	# Your existing undo_redo hook can call bake_copies() once it's in place
	Engine.get_singleton("undo_redo").apply_array_modifier.call_deferred(self)


func set_repeat_levels(value):
	for i in range(len(value)):
		value[i] = max(value[i], 1)

	repeat_levels = value

	while len(repeat_levels) > len(repeat_offsets):
		repeat_offsets.append(Vector3(1, 0, 0))

	while len(repeat_levels) < len(repeat_offsets):
		repeat_offsets.pop_back()

	_adjust_copies()


func set_repeat_offsets(value):
	if len(value) != len(repeat_offsets):
		return

	repeat_offsets = value
	_adjust_position_of_copies()


func set_force_refresh(value):
	_adjust_copies()


func _adjust_copies():
	_clear_hooks()

	var total_copy_count = _get_total_copy_count()
	if total_copy_count <= 1:
		return  # Nothing to repeat

	for orig_child in get_children():
		if _is_hook(orig_child):
			continue

		var hook = Node3D.new()
		hook.name = _get_hook_name(orig_child)
		add_child(hook)
		_hooks[hook.name] = hook

		for index in range(1, total_copy_count):
			var local_offset = _get_offset_for_index(index)

			var copy = orig_child.duplicate()
			copy.translate(local_offset)
			hook.add_child(copy)


func _adjust_position_of_copies():
	var total_copy_count = _get_total_copy_count()

	for orig_child in get_children():
		if _is_hook(orig_child):
			continue

		var hook = _hooks.get(_get_hook_name(orig_child))
		if hook == null:
			printerr("Corresponding hook not found: ", orig_child.name)
			return

		for index in range(1, total_copy_count):
			var local_offset = _get_offset_for_index(index)
			var copy = hook.get_children()[index - 1]
			copy.position = orig_child.position + local_offset


## Moves the generated copies out of their hooks into the real scene tree,
## so they are saved with the scene, then turns the modifier off.
func _bake_copies():
	var scene_root = get_tree().edited_scene_root
	if scene_root == null:
		printerr("No edited scene root found, can't bake copies")
		return

	var originals = get_children().filter(func(c): return not _is_hook(c))

	for orig_child in originals:
		var hook = _hooks.get(_get_hook_name(orig_child))
		if hook == null:
			continue

		var index := 1
		for copy in hook.get_children():
			hook.remove_child(copy)
			copy.name = "%s_copy%d" % [orig_child.name, index]
			index += 1

			add_child(copy)
			_set_owner_recursive(copy, scene_root)

	_clear_hooks()

	# The baked copies are now direct children, so the modifier must stop
	# generating copies or it would duplicate them again.
	repeat_levels = [1]


## Returns the offset for a given copy index, combining every repeat level.
func _get_offset_for_index(index: int) -> Vector3:
	var temp_index = index
	var local_offset = Vector3()
	for i in range(len(repeat_levels)):
		var repeat_level = repeat_levels[i]
		var repeat_offset = repeat_offsets[i]
		var coordinate = temp_index % repeat_level
		temp_index = int(temp_index / repeat_level)
		local_offset += repeat_offset * coordinate
	return local_offset


func _get_total_copy_count() -> int:
	var total = 1
	for level in repeat_levels:
		total *= level
	return total


func _clear_hooks():
	for child in get_children():
		if _is_hook(child):
			remove_child(child)
			child.queue_free()
	_hooks.clear()


func _is_hook(node: Node) -> bool:
	return node.name.begins_with(_get_hook_name_prefix())


func _set_owner_recursive(node: Node, new_owner: Node):
	node.owner = new_owner
	for child in node.get_children():
		_set_owner_recursive(child, new_owner)


func _get_hook_name_prefix():
	return "_array_modifier_hook_" + str(get_instance_id())


func _get_hook_name(child):
	return _get_hook_name_prefix() + "_" + str(child.get_instance_id())
