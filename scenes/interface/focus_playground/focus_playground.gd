class_name FocusPlayground
extends Control

const SENSITIVITY: float = 0.005
@onready var blur_c_rect: ColorRect = $BlurCRect
@onready var item_mesh_3d: MeshInstance3D = $SubViewport/MeshInstance3D

signal focus_requested

var _dragging: bool = false
var _is_focused: bool = false

var selected_item: ItemRes

func _ready() -> void:
	focus_requested.connect(_on_focus_requested)
	blur_c_rect.modulate.a = 0


func _on_focus_requested():
	if _is_focused or not InventoryManager.selected_item:
		return

	enable_focus()


func enable_focus():
	if _is_focused:
		return

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_is_focused = true
	selected_item = InventoryManager.selected_item
	#item_mesh_3d = selected_item.mesh

	fade(true)

func disable_focus():
	if not _is_focused:
		return

	_is_focused = false
	selected_item = null

	fade(false)


func fade(_bool: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)

	var _val: int

	if _bool:
		_val = 1
	else:
		_val = 0

	tween.tween_property(blur_c_rect, "modulate:a", _val, 0.8)

func _input(event: InputEvent) -> void:
	if not _is_focused:
		return

	if event.is_action_pressed("ui_cancel"):
		disable_focus()

	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if button.button_index == MOUSE_BUTTON_LEFT:
			_dragging = button.pressed
	elif event is InputEventMouseMotion and _dragging:
		var motion: InputEventMouseMotion = event
		item_mesh_3d.global_rotate(Vector3.UP, motion.relative.x * SENSITIVITY)
		item_mesh_3d.global_rotate(Vector3.RIGHT, motion.relative.y * SENSITIVITY)
