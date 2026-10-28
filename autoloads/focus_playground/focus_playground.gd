extends Control

signal focus(_bool: bool)

const SENSITIVITY: float = 0.005

@export var fade_speed: float = 0.9
@onready var blur_c_rect: ColorRect = $BlurCRect
@onready var item_mesh_3d: MeshInstance3D = $SubViewport/MeshInstance3D

var _dragging: bool = false
var is_focused: bool = false

var focused_item: ItemRes
var focused_item_slot_idx: int


func _ready() -> void:
	blur_c_rect.modulate.a = 0


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

	if event.is_action("lmb"):
		print("clicl")
		try_and_combine()

	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if button.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = button.pressed
	elif event is InputEventMouseMotion and _dragging:
		var motion: InputEventMouseMotion = event
		item_mesh_3d.global_rotate(Vector3.UP, motion.relative.x * SENSITIVITY)
		item_mesh_3d.global_rotate(Vector3.RIGHT, motion.relative.y * SENSITIVITY)
