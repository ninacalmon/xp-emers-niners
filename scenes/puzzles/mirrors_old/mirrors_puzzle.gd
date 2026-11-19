class_name MirrorPuzzle
extends Puzzle


@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var interaction_area: InteractionArea = $InteractionArea

@export var interaction_area_collision: CollisionShape3D
@export var door: DoubleDoorAction

@onready var mirror_a_full_mesh: Node3D = $mirror_a_full
@onready var mirror_b_full_mesh: Node3D = $mirror_b_full
@onready var mirror_c_full_mesh: Node3D = $mirror_c_full

@onready var slot_1: Marker3D = $Slot1
@onready var slot_2: Marker3D = $Slot2
@onready var slot_3: Marker3D = $Slot3


var puzzle_already_started: bool = false
var is_active: bool = false
var started_frame: int = -1

# Correct order of item ids: slot 1, slot 2, slot 3.
var correct_order: Array[String] = ["mirror_c_full", "mirror_a_full", "mirror_b_full"]

var placed_items: Array[ItemRes] = []
var slots: Array[Marker3D] = []


var puzzle_solved: bool = false:
	set(value):
		puzzle_solved = value
		if value == true:
			interaction_area.queue_free()


func _ready() -> void:
	slots = [slot_1, slot_2, slot_3]
	setup_puzzle()


func setup_puzzle() -> void:
	clean_desk()


func enable_interaction() -> void:
	clean_desk()
	set_interaction_enabled(true)


func set_interaction_enabled(enabled: bool) -> void:
	interaction_area_collision.set_deferred("disabled", not enabled)


func start() -> void:
	if puzzle_solved or is_active:
		return
	is_active = true
	started_frame = Engine.get_process_frames()
	PuzzleManager.puzzle_started.emit(lock_player_movement)
	if not puzzle_already_started:
		puzzle_already_started = true
	phantom_camera_3d.priority = 100
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func finish(solved: bool) -> void:
	is_active = false
	if solved:
		door.open_door()

	if solved:
		print("VOCÊ CONSEGUIU")
		puzzle_solved = true
		await get_tree().create_timer(1).timeout
	else:
		clean_desk()

	phantom_camera_3d.priority = 0
	PuzzleManager.puzzle_ended.emit(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if Engine.get_process_frames() == started_frame:
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		finish(false)
	elif event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		try_place_selected_item()


func try_place_selected_item() -> void:
	var selected: ItemRes = InventoryManager.selected_item
	if selected == null:
		return

	var mirror_mesh: Node3D = get_mirror_mesh(selected)
	if mirror_mesh == null:
		InventoryManager.tried_wrong_item()
		return

	# Put the mirror I'm holding on the current slot's marker
	var current_slot: Marker3D = slots[placed_items.size()]
	mirror_mesh.global_position = current_slot.global_position
	mirror_mesh.visible = true
	placed_items.append(selected)
	InventoryManager.use_item()

	if placed_items.size() == slots.size():
		finish(is_order_correct())


func get_mirror_mesh(item: ItemRes) -> Node3D:
	match item.id:
		"mirror_a_full":
			return mirror_a_full_mesh
		"mirror_b_full":
			return mirror_b_full_mesh
		"mirror_c_full":
			return mirror_c_full_mesh
	return null


func is_order_correct() -> bool:
	for i: int in range(correct_order.size()):
		if placed_items[i].id != correct_order[i]:
			return false
	return true


func clean_desk() -> void:
	for item: ItemRes in placed_items:
		InventoryManager.add_new_item(item)
	placed_items.clear()

	mirror_a_full_mesh.visible = false
	mirror_b_full_mesh.visible = false
	mirror_c_full_mesh.visible = false
