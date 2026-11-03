class_name AstrolabusPuzzle
extends Puzzle

@onready var pointer_pivot: Node3D = $PointerPivot
@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var interaction_area: InteractionArea = $InteractionArea
@export var button_action_trigger: ButtonActionTrigger
@export var astrolabus_pointer: Node3D
@export var button_mesh: MeshInstance3D

const STARTING_VALUE: int = 0
const CORRECT_VALUE: int = 75

const STEP: int = 5
const TURN_SPEED: float = 0.2
const FULL_TURN: int = 360

var current_value: int = 0
var is_moving: bool = false

var dial_value: int

var puzzle_already_started: bool = false
var is_active: bool = false

var puzzle_solved: bool = false:
	set(value):
		puzzle_solved = value
		if value == true:
			interaction_area.queue_free()


func start():
	is_active = true
	PuzzleManager.puzzle_started.emit(lock_player_movement)
	if not puzzle_already_started:
		puzzle_already_started = true
	phantom_camera_3d.priority = 100
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func finish(solved: bool):
	is_active = false

	if solved:
		print("VOCÊ CONSEGUIU")
		puzzle_solved = true
		await get_tree().create_timer(1).timeout

	phantom_camera_3d.priority = 0
	PuzzleManager.puzzle_ended.emit()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _ready() -> void:
	button_action_trigger.button_pressed.connect(_on_button_pressed)
	button_action_trigger.button_released.connect(_on_button_released)
	setup_puzzle()


func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event.is_action_pressed("astrolabus_pointer_left"):
		await move_pointer(1)
	elif event.is_action_pressed("astrolabus_pointer_right"):
		await move_pointer(-1)
	elif event.is_action_pressed("ui_cancel"):
		finish(false)


func setup_puzzle() -> void:
	astrolabus_pointer.rotation.y = deg_to_rad(-49.973)
	pointer_pivot.rotation.y = deg_to_rad(STARTING_VALUE)


func move_pointer(dir: int) -> void:
	if is_moving:
		return
	is_moving = true

	var target_value: int = current_value + STEP * dir

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(
		pointer_pivot,
		"rotation:y",
		deg_to_rad(float(target_value)),
		TURN_SPEED
	)
	await tween.finished

	current_value = posmod(target_value, FULL_TURN)
	pointer_pivot.rotation.y = deg_to_rad(float(current_value))

	is_moving = false

	dial_value  = get_dial_value()
	#print("ANGLE: ", current_value, " | DIAL: ", dial_value)



func get_dial_value() -> int:
	return posmod(-current_value, FULL_TURN)



func _on_button_pressed():
	button_press_visual(true)


func _on_button_released():
	button_press_visual(false)
	if dial_value == CORRECT_VALUE:
		finish(true)
		print("solved!")
	else:
		print("wrong value")


func button_press_visual(pressed: bool):
	var pressed_y = 0.005
	if pressed:
		button_mesh.position.y -= pressed_y
	else:
		button_mesh.position.y += pressed_y
		
