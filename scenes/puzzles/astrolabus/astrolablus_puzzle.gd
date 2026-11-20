class_name AstrolabusPuzzle
extends Puzzle


@onready var phantom_camera_3d: PhantomCamera3D = $PhantomCamera3D
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var audio_stream_player_try: AudioStreamPlayer = $AudioStreamPlayerTry
@onready var audio_stream_player_fit: AudioStreamPlayer = $AudioStreamPlayerFit
@onready var audio_stream_player_step: AudioStreamPlayer = $AudioStreamPlayerStep

@export var interaction_area_collision: CollisionShape3D

@export var pointer_pivot: Node3D
@export var button_action_trigger: ButtonActionTrigger
@export var astrolabus_pointer: Node3D
@export var button_mesh: MeshInstance3D
@export var astrolabus: Node3D
@export var step_sound_interval: float = 5.0

@export_group("Shake Feedback")
@export var shake_intensity: float = 0.01
@export var shake_duration: float = 0.03

var _shake_tween: Tween
var _astrolabus_original_position: Vector3

var _sound_angle_accumulator: float = 0.0
const STARTING_VALUE: int = 0
const CORRECT_VALUE: int = 75

const STEP: int = 5
const TURN_SPEED: float = 0.2
const FULL_TURN: int = 360

const DRAG_SENSITIVITY: float = 0.5
const DRAG_DIRECTION: float = -1.0 

var is_dragging: bool = false
var drag_angle: float = 0.0

var current_value: int = 0
var is_moving: bool = false

var dial_value: int

var puzzle_already_started: bool = false
var is_active: bool = false

var last_mouse_angle: float = 0.0

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
	is_dragging = false

	if solved:
		audio_stream_player_fit.play()
		puzzle_solved = true
		await get_tree().create_timer(1).timeout

	phantom_camera_3d.priority = 0
	PuzzleManager.puzzle_ended.emit(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _ready() -> void:
	button_action_trigger.button_pressed.connect(_on_button_pressed)
	button_action_trigger.button_released.connect(_on_button_released)
	setup_puzzle()

	astrolabus.hide()
	interaction_area_collision.disabled = true

	_astrolabus_original_position = astrolabus.position


func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				_start_drag()
			else:
				_end_drag()
	elif event is InputEventMouseMotion and is_dragging:
		var motion: InputEventMouseMotion = event as InputEventMouseMotion
		_drag_pointer(motion.relative.x)
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
	_update_rotation_audio(float(STEP * dir))

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
	audio_stream_player_try.play()


func _on_button_released():
	button_press_visual(false)
	if dial_value == CORRECT_VALUE:
		finish(true)
		print("solved!")
	else:
		shake()
		print("wrong value")


func button_press_visual(pressed: bool):
	var pressed_y = 0.005
	if pressed:
		button_mesh.position.y -= pressed_y
	else:
		button_mesh.position.y += pressed_y
		



func _get_mouse_angle() -> float:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var center: Vector2 = camera.unproject_position(pointer_pivot.global_position)
	var offset: Vector2 = get_viewport().get_mouse_position() - center
	return atan2(offset.y, offset.x)


func _start_drag() -> void:
	if is_moving:
		return
	is_dragging = true
	drag_angle = float(current_value)
	last_mouse_angle = _get_mouse_angle()


func _drag_pointer(_delta_x: float) -> void:
	var mouse_angle: float = _get_mouse_angle()
	var delta_angle: float = angle_difference(last_mouse_angle, mouse_angle)
	last_mouse_angle = mouse_angle

	var rotation_delta: float = rad_to_deg(delta_angle) * DRAG_DIRECTION

	_update_rotation_audio(rotation_delta)

	drag_angle += rotation_delta
	pointer_pivot.rotation.y = deg_to_rad(drag_angle)
	



func _end_drag() -> void:
	if not is_dragging:
		return
	is_dragging = false
	is_moving = true

	var target_value: int = roundi(drag_angle / float(STEP)) * STEP

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		pointer_pivot,
		"rotation:y",
		deg_to_rad(float(target_value)),
		TURN_SPEED
	)
	await tween.finished

	current_value = posmod(target_value, FULL_TURN)
	pointer_pivot.rotation.y = deg_to_rad(float(current_value))
	dial_value = get_dial_value()
	is_moving = false


func enable_interaction():
	astrolabus.show()
	interaction_area_collision.disabled = false


func _update_rotation_audio(delta_angle: float) -> void:
	_sound_angle_accumulator += absf(delta_angle)

	if _sound_angle_accumulator >= step_sound_interval:
		_sound_angle_accumulator = fmod(
			_sound_angle_accumulator,
			step_sound_interval
		)
		audio_stream_player_step.play()


func shake() -> void:
	if _shake_tween and _shake_tween.is_running():
		_shake_tween.kill()

	astrolabus.position = _astrolabus_original_position

	_shake_tween = create_tween()

	for i in range(4):
		var offset: float = shake_intensity * (1.0 - float(i) / 4.0)
		var direction: float = -1.0 if i % 2 == 0 else 1.0

		_shake_tween.tween_property(
			astrolabus,
			"position:x",
			_astrolabus_original_position.x + offset * direction,
			shake_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_shake_tween.tween_property(
		astrolabus,
		"position",
		_astrolabus_original_position,
		shake_duration
	)
