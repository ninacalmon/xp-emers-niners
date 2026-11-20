extends ActionTrigger
class_name RotateAction

@export var rotate_speed_degrees: float = 50.0
@export var rich_text_label: RichTextLabel
@export var mirror_stand: Mirror
@export var rotate_step_degrees: float = 15.0
@export var rotate_duration: float = 0.15

@export_group("Missing Mirror")
## If false, this stand starts without a mirror: it can't be rotated until a mirror item is placed.
@export var starts_with_mirror: bool = true
## Text shown on the label while looking at a stand that has no mirror.
@export_multiline var missing_mirror_text: String = "Algo está faltando."
## Items that count as a mirror. The ORDER matters: index 0 -> Mirror A, 1 -> Mirror B, 2 -> Mirror C.
@export var accepted_items: Array[ItemRes] = [preload("uid://cka13d4wlnvfr"), preload("uid://dymw8vckx5n6n"), preload("uid://bsdb5amilihps")]

@export_group("Mirror Models (inside MirrorMesh)")
## Model used by stands that start with a mirror.
@export var mirror_start_model: Node3D
@export var mirror_a_model: Node3D
@export var mirror_b_model: Node3D
@export var mirror_c_model: Node3D

var is_interacting: bool = false
var has_mirror: bool = true
var is_hovered: bool = false
var placed_index: int = -1
var rotate_text: String = ""


func _ready() -> void:
	super()
	rotate_text = rich_text_label.text
	rich_text_label.hide()
	has_mirror = starts_with_mirror
	placed_index = -1
	_sync_mirror_enabled()
	_update_models()


func trigger() -> void:
	if not has_mirror:
		_try_place_mirror()
		return

	# Stand already has a mirror: items are never used here, it only enters rotation mode.
	is_interacting = true
	_update_label()
	GetEntity.get_player().is_puzzle_locked = true


func ray_enter() -> void:
	is_hovered = true
	_update_label()


func ray_exit() -> void:
	is_hovered = false
	_update_label()


func _try_place_mirror() -> void:
	if has_mirror:
		return

	var item: ItemRes = InventoryManager.selected_item
	if item == null:
		return

	var index: int = accepted_items.find(item)
	if index == -1 or index >= _get_placed_models().size():
		InventoryManager.tried_wrong_item()
		return

	InventoryManager.use_item()
	has_mirror = true
	placed_index = index
	_sync_mirror_enabled()
	_update_models()
	_update_label()


func _get_placed_models() -> Array[Node3D]:
	var models: Array[Node3D] = [mirror_a_model, mirror_b_model, mirror_c_model]
	return models


func _update_models() -> void:
	var placed_models: Array[Node3D] = _get_placed_models()

	if mirror_start_model != null:
		mirror_start_model.visible = has_mirror and placed_index == -1

	for i: int in placed_models.size():
		var model: Node3D = placed_models[i]
		if model != null:
			model.visible = has_mirror and placed_index == i


func _sync_mirror_enabled() -> void:
	var parent_mirror: Mirror = get_parent() as Mirror
	if parent_mirror != null:
		parent_mirror.enabled = has_mirror


func _update_label() -> void:
	if is_interacting:
		rich_text_label.text = rotate_text
		rich_text_label.show()
	elif is_hovered and not has_mirror:
		rich_text_label.text = missing_mirror_text
		rich_text_label.show()
	else:
		rich_text_label.hide()


func _physics_process(delta: float) -> void:
	if not is_interacting:
		return

	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("walk_backwards"):
		is_interacting = false
		_update_label()
		GetEntity.get_player().is_puzzle_locked = false

	var input: float = Input.get_axis("rotate_right", "rotate_left")
	if input != 0.0:
		mirror_stand.rotate_y(deg_to_rad(rotate_speed_degrees) * input * delta)
