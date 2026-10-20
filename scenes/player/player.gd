class_name Player
extends CharacterBody3D

const STEP_HEIGHT: float = 0.25

@export var speed = 7.0
@export var run_speed = 11.0

@onready var head: Node3D = $Head
@onready var footstep_player: Node = $FootstepPlayer

var is_dialogue_locked: bool = false

#region ConfigVariables
var h_mouse_sensitivity: float
var v_mouse_sensitivity: float
#endregion


func _ready() -> void:
	ConfigValues.update_config_values.connect(update_config_values)
	update_config_values(ConfigValues.ConfigField.CONTROLS)

	## dialogue locking to make player static during dialogue! vvv
	DialogueManager.dialogue_started.connect(func(_res): is_dialogue_locked = true)
	DialogueManager.dialogue_ended.connect(func(_res): is_dialogue_locked = false)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if is_dialogue_locked:
		return

	## NOTE: mouse capturing and freeing, temporary and for DEBUG ONLY!
	if event.is_action_pressed("rmb"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.is_action_pressed("lmb"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# player and camera rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * h_mouse_sensitivity)
		head.rotate_x(-event.relative.y * v_mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.55)


func _physics_process(delta: float) -> void:
	if is_dialogue_locked:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir: Vector2 = Input.get_vector(
		"walk_left",
		"walk_right",
		"walk_fowards",
		"walk_backwards"
	)

	var current_speed = run_speed if Input.is_action_pressed("run") else speed
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		var horizontal_motion: Vector3 = Vector3(
			velocity.x * delta,
			0.0,
			velocity.z * delta
		)

		try_step_up(horizontal_motion)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


# climbing stairs vvv
func try_step_up(move_direction: Vector3) -> bool:
	if not is_on_floor():
		return false

	if not test_move(global_transform, move_direction):
		return false

	var up_motion: Vector3 = Vector3.UP * STEP_HEIGHT

	if test_move(global_transform, up_motion):
		return false

	var raised_transform: Transform3D = global_transform
	raised_transform.origin += up_motion

	if test_move(raised_transform, move_direction):
		return false

	global_position += up_motion
	return true


func update_config_values(config_field: ConfigValues.ConfigField):
	match config_field:
		ConfigValues.ConfigField.CONTROLS:
			h_mouse_sensitivity = ConfigValues.h_mouse_sensitivity
			v_mouse_sensitivity = ConfigValues.v_mouse_sensitivity
