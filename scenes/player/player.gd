class_name Player
extends CharacterBody3D

@export var speed = 5.0

@onready var head: Node3D = $Head

var is_dialogue_locked: bool = false

#region ConfigVariables
var h_mouse_sensitivity: float
var v_mouse_sensitivity: float
#endregion


func _ready() -> void:
	TranslationServer.set_locale("pt")
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
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.0)


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

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func update_config_values(config_field: ConfigValues.ConfigField):
	match config_field:
		ConfigValues.ConfigField.CONTROLS:
			h_mouse_sensitivity = ConfigValues.h_mouse_sensitivity
			v_mouse_sensitivity = ConfigValues.v_mouse_sensitivity
