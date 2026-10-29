extends Control

signal focus(_bool: bool)

const SENSITIVITY: float = 0.005
@export var fade_speed: float = 0.9
@export var arcball_radius: float = 250.0
@export var rotation_speed: float = 1.0

@onready var blur_c_rect: ColorRect = $BlurCRect
@onready var item_mesh_3d: MeshInstance3D = $SubViewport/MeshInstance3D
@onready var follow_mouse_spr: Sprite2D = $BlurCRect/FollowMouseSpr
@onready var exit_tex_button: TextureButton = $BlurCRect/MarginContainer/VBoxContainer/ExitTexButton


var _dragging: bool = false
var is_focused: bool = false

var focused_item: ItemRes
var focused_item_slot_idx: int

var _last_arcball_vec: Vector3 = Vector3.ZERO

var tex_follow_mouse: bool = false

func _ready() -> void:
	blur_c_rect.modulate.a = 0

	InventoryManager.selected_item_changed.connect(_on_inventory_selected_object_changed)
	exit_tex_button.pressed.connect(disable_focus)


func focus_request() -> bool:
	if is_focused or not InventoryManager.selected_item:
		return false

	enable_focus()
	return true


func try_and_combine():
	var combining_item: ItemRes = InventoryManager.selected_item
	var combining_item_slot_idx: int = InventoryManager.selected_slot_idx

	if focused_item.combining_item == combining_item:
		InventoryManager.use_item(focused_item_slot_idx)
		InventoryManager.use_item(combining_item_slot_idx)
		InventoryManager.add_new_item(get_combined_item(), true)
		return true
	else:
		InventoryManager.tried_wrong_item(combining_item_slot_idx)


func get_combined_item() -> ItemRes:
	focused_item.texture = focused_item.combined_texture
	#focused_item.mesh = focused_item.combined_mesh
	focused_item.id = focused_item.combining_id
	focused_item.name_tr_key = focused_item.combining_name_tr_key

	return focused_item


func enable_focus():
	if is_focused:
		return

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_focused = true
	focus.emit(true)
	focused_item = InventoryManager.selected_item
	focused_item_slot_idx = InventoryManager.selected_slot_idx
	#item_mesh_3d = focused_item.mesh

	fade(true)


func disable_focus():
	if not is_focused:
		return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InventoryManager.change_slot(focused_item_slot_idx - InventoryManager.selected_slot_idx)
	is_focused = false
	focus.emit(false)
	focused_item = null

	fade(false)


func fade(_bool: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)

	var _val: int

	if _bool:
		_val = 1
	else:
		_val = 0

	tween.tween_property(blur_c_rect, "modulate:a", _val, fade_speed)


func _input(event: InputEvent) -> void:
	if not is_focused:
		return

	if event.is_action_pressed("ui_cancel"):
		disable_focus()

	if event.is_action("focus_combine_item"):
		try_and_combine()

	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		_dragging = button.is_action_pressed("focus_rotate_item")
		if _dragging:
			_last_arcball_vec = _get_arcball_vector(button.position)
	elif event is InputEventMouseMotion and _dragging:
		var motion: InputEventMouseMotion = event
		var current_vec: Vector3 = _get_arcball_vector(motion.position)
		var axis: Vector3 = _last_arcball_vec.cross(current_vec)

		if axis.length_squared() > 0.000001:
			var angle: float = _last_arcball_vec.angle_to(current_vec) * rotation_speed
			item_mesh_3d.global_rotate(axis.normalized(), angle)

		_last_arcball_vec = current_vec

		item_mesh_3d.transform = item_mesh_3d.transform.orthonormalized()


func _get_arcball_vector(screen_pos: Vector2) -> Vector3:
	var center: Vector2 = get_viewport_rect().size * 0.5
	var p: Vector2 = (screen_pos - center) / arcball_radius
	p.y = -p.y

	var length_sq: float = p.length_squared()
	if length_sq <= 1.0:
		return Vector3(p.x, p.y, sqrt(1.0 - length_sq))

	return Vector3(p.x, p.y, 0.0).normalized()


func _on_inventory_selected_object_changed(item: ItemRes):
	if not is_focused:
		return

	if item == focused_item or not item:
		follow_mouse_spr.hide()
		item_follow_mouse()
		return

	follow_mouse_spr.show()
	item_follow_mouse(item.texture)


func item_follow_mouse(item_tex: Texture2D = null):
	follow_mouse_spr.texture = item_tex


func _process(_delta: float) -> void:
	follow_mouse_spr.global_position = get_global_mouse_position()


func attach_to_slot(slot: Control) -> void:
	if get_parent() != null:
		get_parent().remove_child(self)
	slot.add_child(self)
