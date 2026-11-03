extends Node3D

@onready var pointer_pivot: Node3D = $PointerPivot
@export var button_action_trigger: ButtonActionTrigger
@export var astrolabus_pointer: Node3D
@export var button_mesh: MeshInstance3D

const CORRECT_VALUE: int = 75
const STARTING_VALUE_MIN: int = -350
const STARTING_VALUE_MAX: int = -150

const STEP: int = 5
const TURN_SPEED: float = 0.2
const FULL_TURN: int = 360

var current_value: int = 0
var is_moving: bool = false

var dial_value: int

func _ready() -> void:
	button_action_trigger.button_pressed.connect(_on_button_pressed)
	button_action_trigger.button_released.connect(_on_button_released)
	setup_puzzle()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("astrolabus_pointer_left"):
		await move_pointer(1)
	elif event.is_action_pressed("astrolabus_pointer_right"):
		await move_pointer(-1)


func setup_puzzle() -> void:
	astrolabus_pointer.rotation.y = deg_to_rad(-49.973)
	current_value = posmod(
		random_multiple_of(STEP, STARTING_VALUE_MIN, STARTING_VALUE_MAX),
		FULL_TURN
	)
	pointer_pivot.rotation.y = deg_to_rad(float(current_value))


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


func random_multiple_of(mult: int, min_val: int, max_val: int) -> int:
	@warning_ignore("integer_division")
	return randi_range(ceili(min_val / mult), floori(max_val / mult)) * mult


func _on_button_pressed():
	button_press_visual(true)


func _on_button_released():
	button_press_visual(false)
	if dial_value == CORRECT_VALUE:
		print("solved!")
	else:
		print("wrong value")


func button_press_visual(pressed: bool):
	var pressed_y = 0.005
	if pressed:
		button_mesh.position.y -= pressed_y
	else:
		button_mesh.position.y += pressed_y
		
