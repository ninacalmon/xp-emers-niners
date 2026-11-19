extends ActionTrigger
class_name RotateAction

@export var rotate_speed_degrees: float = 50.0
@export var rich_text_label: RichTextLabel
@export var mirror_stand: Mirror
@export var rotate_step_degrees: float = 15.0
@export var rotate_duration: float = 0.15

var is_interacting: bool = false


func _ready() -> void:
	super()
	rich_text_label.hide()


func trigger() -> void:
	is_interacting = true
	rich_text_label.show()
	GetEntity.get_player().is_puzzle_locked = true


func ray_enter() -> void:
	pass


func ray_exit() -> void:
	pass


func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_cancel"):
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if not is_interacting:
		return

	if Input.is_action_just_pressed("ui_cancel"):
		is_interacting = false
		rich_text_label.hide()
		GetEntity.get_player().is_puzzle_locked = false

	var input: float = Input.get_axis("rotate_right", "rotate_left")
	if input != 0.0:
		mirror_stand.rotate_y(deg_to_rad(rotate_speed_degrees) * input * delta)
