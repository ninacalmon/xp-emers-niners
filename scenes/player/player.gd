class_name Player
extends CharacterBody3D


const STEP_HEIGHT: float = 0.32
const CROUCH_HEIGHT: float = 1.2
const CROUCH_SPEED_LERP: float = 10.0
const STAND_HEIGHT: float = 1.85

@export var player_ray_cast: PlayerRayCast

@export var speed = 7.0
@export var run_speed = 11.0
@export var crouch_speed = 2.0

@export var drunk_overlay: ColorRect

@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _is_drunk: bool = false
const DRUNK_DURATION: float = 30.0
var _drunk_time: float = 0.0
var _drunk_id: int = 0
var drunk_dialogue: DialogueResource = preload("uid://bvnutokokwyyg")
var _first_time_drunk: bool = true


var is_dialogue_locked: bool = false:
	set(value):
		is_dialogue_locked = value
		player_ray_cast.deactivate("dialogue", value)

var is_focus_locked: bool = false:
	set(value):
		is_focus_locked = value
		player_ray_cast.deactivate("focus", value)

var is_puzzle_locked: bool = false:
	set(value):
		is_puzzle_locked = value
		player_ray_cast.deactivate("puzzle", value)

var is_cutscene_locked: bool = false:
	set(value):
		is_cutscene_locked = value
		player_ray_cast.deactivate("cutscene", value)


#region ConfigVariables
var h_mouse_sensitivity: float
var v_mouse_sensitivity: float
#endregion

var original_head_rot: Vector3

func _ready() -> void:
	original_head_rot = head.rotation
	#DialogueData.player_in_booth(self)
	ConfigValues.update_config_values.connect(update_config_values)
	update_config_values(ConfigValues.ConfigField.CONTROLS)

	## dialogue locking to make player static during dialogue, focus and puzzle! vvv
	DialogueManager.dialogue_started.connect(func(_res): is_dialogue_locked = true)
	DialogueManager.dialogue_ended.connect(func(_res): is_dialogue_locked = false)
	FocusPlayground.focus.connect(func(_bool: bool): is_focus_locked = _bool)
	PuzzleManager.puzzle_started.connect(func(lock_player: bool): is_puzzle_locked = lock_player)
	PuzzleManager.puzzle_ended.connect(func(_p): is_puzzle_locked = false)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	drunk_overlay.hide()



func _input(event: InputEvent) -> void:
	if is_dialogue_locked or is_focus_locked or is_puzzle_locked or is_cutscene_locked:
		return

	## NOTE: mouse capturing and freeing, temporary and for DEBUG ONLY!
	#if event.is_action_pressed("rmb"):
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#
	#if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and event.is_action_pressed("lmb"):
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# player and camera rotation
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * h_mouse_sensitivity)
		head.rotate_x(-event.relative.y * v_mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.55)


func _physics_process(delta: float) -> void:
	if is_dialogue_locked or is_focus_locked or is_puzzle_locked or is_cutscene_locked:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	_update_crouch(delta)

	var input_dir: Vector2 = Input.get_vector(
		"walk_left",
		"walk_right",
		"walk_fowards",
		"walk_backwards"
	)

	if _is_drunk:
		_drunk_time += delta
		input_dir = input_dir.rotated(sin(_drunk_time * 2.0) * 0.6)

	var current_speed: float = speed
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
	elif Input.is_action_pressed("run"):
		current_speed = run_speed

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

# crouching
func _update_crouch(delta: float) -> void:
	var target_height: float = STAND_HEIGHT
	if Input.is_action_pressed("crouch"):
		target_height = CROUCH_HEIGHT

	var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	capsule.height = lerpf(capsule.height, target_height, CROUCH_SPEED_LERP * delta)
	collision_shape.position.y = capsule.height * 0.5
	head.position.y = capsule.height


func update_config_values(config_field: ConfigValues.ConfigField):
	match config_field:
		ConfigValues.ConfigField.CONTROLS:
			h_mouse_sensitivity = ConfigValues.h_mouse_sensitivity
			v_mouse_sensitivity = ConfigValues.v_mouse_sensitivity


func get_drunk() -> void:
	if _first_time_drunk:
		_first_time_drunk = false
		DialogueManager.show_dialogue_balloon(drunk_dialogue, "start")
		await DialogueManager.dialogue_ended


	_drunk_id += 1
	var my_id: int = _drunk_id

	_is_drunk = true
	drunk_overlay.show()


	await get_tree().create_timer(DRUNK_DURATION).timeout

	if my_id != _drunk_id:
		return

	_is_drunk = false
	drunk_overlay.hide()


func look_at_target(target_pos: Vector3, duration: float = 0.5) -> void:
	var to_target: Vector3 = target_pos - head.global_position
	var horizontal: Vector3 = Vector3(to_target.x, 0.0, to_target.z)

	var target_yaw: float = atan2(-horizontal.x, -horizontal.z)
	var target_pitch: float = clampf(
		atan2(to_target.y, horizontal.length()),
		-1.2,
		1.55
	)


	var start_yaw: float = rotation.y
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(
		func(weight: float) -> void: rotation.y = lerp_angle(start_yaw, target_yaw, weight),
		0.0,
		1.0,
		duration
	)
	tween.tween_property(head, "rotation:x", target_pitch, duration)

	await tween.finished
