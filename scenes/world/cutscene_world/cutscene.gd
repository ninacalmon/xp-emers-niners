extends Node

@onready var phantom_camera_monastery_view: PhantomCamera3D = $"../Cameras/PhantomCameraMonasteryView"
@onready var phantom_camera_corridor_view: PhantomCamera3D = $"../Cameras/PhantomCameraCorridorView"
@onready var phantom_camera_brothers_view: PhantomCamera3D = $"../Cameras/PhantomCameraBrothersView"

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var camera_3d: Camera3D = $"../Camera3D"


var dialogue_res = preload("uid://dhu5fv6qml7oi")

var start_anim: bool = true

func _ready() -> void:
	camera_3d.fov = 75.0

	phantom_camera_monastery_view.priority = 10
	animation_player.play("monastery_view")
	await animation_player.animation_finished
	phantom_camera_monastery_view.priority = 0

	animation_player.play("corridor_view")
	await animation_player.animation_finished
	phantom_camera_corridor_view.priority = 0

	animation_player.play("brothers_view")
	await animation_player.animation_finished
	phantom_camera_brothers_view.priority = 0

	animation_player.play("sun_view")
	animation_player.pause()

	var ballon: DialogueManagerExampleBalloon = DialogueManager.show_dialogue_balloon(dialogue_res, "start")
	ballon.line_finished.connect(_on_line_finished)

func _on_line_finished(_line: DialogueLine):
	if not start_anim:
		return

	animation_player.play()
