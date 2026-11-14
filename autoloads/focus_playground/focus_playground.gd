extends Control

signal focus(_bool: bool)

const SENSITIVITY: float = 0.005
@export var combine_radius: float = 600.0
@export var fade_speed: float = 0.9
@export var arcball_radius: float = 250.0
@export var rotation_speed: float = 1.0

@onready var blur_c_rect: ColorRect = $BlurCRect
@onready var sub_viewport: SubViewport = $SubViewport
@onready var follow_mouse_spr: Sprite2D = $BlurCRect/FollowMouseSpr
@onready var exit_tex_button: TextureButton = $BlurCRect/MarginContainer/VBoxContainer/ExitTexButton

var item_mesh_3d: Node3D

var _dragging: bool = false
var is_focused: bool = false

var focused_item: ItemRes
var focused_item_slot_idx: int

var _last_arcball_vec: Vector3 = Vector3.ZERO

var tex_follow_mouse: bool = false

var _new_focus_item: ItemFocusView

var _dragging_item: ItemRes
var _dragging_item_slot_idx: int


#region built-in callbacks

func _ready() -> void:
	blur_c_rect.modulate.a = 0

	InventoryManager.selected_item_changed.connect(_on_inventory_selected_object_changed)
	exit_tex_button.pressed.connect(disable_focus)



func _process(_delta: float) -> void:
	follow_mouse_spr.global_position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if not is_focused:
		return

	if Input.is_action_pressed("zoom_toggle"):
			if event.is_action_pressed("zoom_in"):
				_zoom_focus_item(-1)
				get_viewport().set_input_as_handled()
				return
			elif event.is_action_pressed("zoom_out"):
				_zoom_focus_item(1)
				get_viewport().set_input_as_handled()
				return

	if event.is_action_pressed("ui_cancel"):
		disable_focus()

	if event.is_action_pressed("rmb"):
			save_viewport_png()
			get_viewport().set_input_as_handled()
			return

	#if event.is_action("focus_combine_item"):
		#try_and_combine()

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

#endregion


#region focus

func focus_request() -> bool:
	if is_focused or not InventoryManager.selected_item:
		return false

	enable_focus()
	return true


func enable_focus() -> void:
	if is_focused:
		return

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	is_focused = true
	focus.emit(true)

	focused_item = InventoryManager.selected_item
	focused_item_slot_idx = InventoryManager.selected_slot_idx

	_build_focus_view()
	fade(true)

	##########################################################################################
	## WARNING: this function should only be activated if you wish to save a new capture
	## of the item.
	#save_viewport_png()
########################################################################################


func disable_focus():
	if not is_focused:
		return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InventoryManager.change_slot(focused_item_slot_idx - InventoryManager.selected_slot_idx)
	is_focused = false
	focus.emit(false)
	focused_item = null
	_new_focus_item.is_active = false

	await fade(false)

	_new_focus_item.revert_rotation()


func fade(_bool: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)

	var _val: int

	if _bool:
		_val = 1
	else:
		_val = 0

	tween.tween_property(blur_c_rect, "modulate:a", _val, fade_speed)
	await tween.finished


func attach_to_slot(slot: Control) -> void:
	if get_parent() != null:
		get_parent().remove_child(self)
	slot.add_child(self)

#endregion


#region item drag and combine

func item_drag_request(item: ItemRes, slot_idx: int) -> bool:
	if item == focused_item or not item:
		return false
	_dragging_item = item
	_dragging_item_slot_idx = slot_idx
	follow_mouse_spr.show()
	item_follow_mouse(_dragging_item.texture)
	return true
	#if item == focused_item or not item:
		#follow_mouse_spr.hide()
		#item_follow_mouse()
		#return


func item_let_down() -> void:
	if _is_dragged_item_near_center():
		try_and_combine()

	_dragging_item = null
	follow_mouse_spr.hide()
	item_follow_mouse()


func item_follow_mouse(item_tex: Texture2D = null):
	follow_mouse_spr.texture = item_tex


func try_and_combine() -> void:
	if not focused_item:
		return 

	var combining_item: ItemRes = _dragging_item
	var combining_item_slot_idx: int = _dragging_item_slot_idx

	if combining_item == null:
		return

	if focused_item.combining_item_id == combining_item.id:
		var result_item: ItemRes = focused_item.result_item

		InventoryManager.use_item(focused_item_slot_idx)
		InventoryManager.use_item(combining_item_slot_idx)
		InventoryManager.add_new_item(result_item, true)

		_swap_focused_item(result_item)
	else:
		InventoryManager.tried_wrong_item(combining_item_slot_idx)

#func get_combined_item() -> ItemRes:
	#focused_item.texture = focused_item.combined_texture
	##focused_item.mesh = focused_item.combined_mesh
	#focused_item.id = focused_item.combining_id
	#focused_item.name_tr_key = focused_item.combining_name_tr_key
#
	#return focused_item

#endregion


#region focus view

func _swap_focused_item(item: ItemRes) -> void:
	focused_item = item

	follow_mouse_spr.hide()
	item_follow_mouse()
	

	_build_focus_view()


func _build_focus_view() -> void:
	for c in sub_viewport.get_children():
		c.queue_free()

	_new_focus_item = focused_item.item_focus_view.instantiate() as ItemFocusView
	sub_viewport.add_child(_new_focus_item)

	item_mesh_3d = _new_focus_item.item_mesh
	_new_focus_item.is_active = true


func _zoom_focus_item(direction: int) -> void:
	if _new_focus_item and _new_focus_item.has_method("zoom"):
		_new_focus_item.zoom(direction)

#endregion


#region helpers

func _is_dragged_item_near_center() -> bool:
	var center: Vector2 = get_viewport_rect().size * 0.5
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	return mouse_pos.distance_to(center) <= combine_radius


func _get_arcball_vector(screen_pos: Vector2) -> Vector3:
	var center: Vector2 = get_viewport_rect().size * 0.5
	var p: Vector2 = (screen_pos - center) / arcball_radius
	p.y = -p.y

	var length_sq: float = p.length_squared()
	if length_sq <= 1.0:
		return Vector3(p.x, p.y, sqrt(1.0 - length_sq))

	return Vector3(p.x, p.y, 0.0).normalized()

#endregion


#region signal callbacks

func _on_inventory_selected_object_changed(item: ItemRes):
	if not is_focused or not item:
		return
	focused_item_slot_idx = InventoryManager.selected_slot_idx
	_swap_focused_item(item)

#endregion


#region screenshot


### this function saves the sub_viewport render as a png.
#func save_viewport_png(dir_path: String = "res://assets/2d/interface/items_capture/EXCLUIR/") -> void:
	#sub_viewport.size = Vector2i(1080, 1080)
	#sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	#await RenderingServer.frame_post_draw
#
	#DirAccess.make_dir_recursive_absolute(dir_path)
#
	#var img: Image = sub_viewport.get_texture().get_image()
	#var full_path: String = dir_path.path_join(focused_item.id + ".png")
#
	#var err: Error = img.save_png(full_path)
	#if err != OK:
		#push_error("Failed to save PNG: %s" % error_string(err))
	#print("captured! - ", focused_item.id)

#endregion
var _is_capturing: bool = false

func save_viewport_png (dir_path: String = "res://assets/2d/interface/items_capture/EXCLUIR/") -> void:
	if _is_capturing or focused_item == null or item_mesh_3d == null:
		return
	_is_capturing = true

	# Cache the id now, since focused_item may change while we await frames.
	var item_id: String = focused_item.id

	var capture_viewport: SubViewport = SubViewport.new()
	capture_viewport.size = Vector2i(1080, 1080)
	capture_viewport.transparent_bg = sub_viewport.transparent_bg
	capture_viewport.msaa_3d = sub_viewport.msaa_3d
	capture_viewport.own_world_3d = true
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(capture_viewport)

	var capture_view: ItemFocusView = focused_item.item_focus_view.instantiate() as ItemFocusView
	capture_viewport.add_child(capture_view)
	# Same orientation the player is currently looking at.
	capture_view.item_mesh.transform = item_mesh_3d.transform

	await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img: Image = capture_viewport.get_texture().get_image()
	capture_viewport.queue_free()

	DirAccess.make_dir_recursive_absolute(dir_path)
	var full_path: String = dir_path.path_join(item_id + ".png")

	var err: Error = img.save_png(full_path)
	if err != OK:
		push_error("Failed to save PNG: %s" % error_string(err))
	else:
		print("captured! - ", item_id)

	_is_capturing = false

#endregion
