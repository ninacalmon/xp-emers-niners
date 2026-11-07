extends Node

@onready var phantom_camera_monastery_view: PhantomCamera3D = $"../Cameras/PhantomCameraMonasteryView"
@onready var phantom_camera_corridor_view: PhantomCamera3D = $"../Cameras/PhantomCameraCorridorView"
@onready var phantom_camera_brothers_view: PhantomCamera3D = $"../Cameras/PhantomCameraBrothersView"
@onready var phantom_camera_sun_view: PhantomCamera3D = $"../Cameras/PhantomCameraSunView"

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var camera_3d: Camera3D = $"../Camera3D"
@onready var hands_overlay: HandsOverlay = $"../HandsOverlay"


var dialogue_res = preload("uid://dhu5fv6qml7oi")

var is_francisco_talking: bool = false
var balloon: DialogueManagerExampleBalloon
var seconds_per_step

func _ready() -> void:
	#TimeManager.set_time(TimeManager.Times.at1200)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	hands_overlay.hide()

	camera_3d.fov = 75.0

	animation_player.play("monastery_view")
	await get_tree().create_timer(6.0).timeout
	phantom_camera_monastery_view.priority = 0

	animation_player.play_backwards("sun_view")

	await get_tree().create_timer(5).timeout

	balloon = DialogueManager.show_dialogue_balloon(dialogue_res, "sun")
	await balloon.ready
	seconds_per_step = balloon.dialogue_label.seconds_per_step
	balloon.dialogue_label.seconds_per_step = 0.08

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_ended(_res: DialogueResource):
	if is_francisco_talking:
		await get_tree().create_timer(1.0).timeout
		return await FadeInOut.change_scene_to("res://scenes/world/world.tscn")

	is_francisco_talking = true
	balloon.dialogue_label.seconds_per_step = seconds_per_step

	animation_player.stop()

	await FadeInOut.fade_in()
	phantom_camera_sun_view.priority = 0
	camera_3d.fov = 75.0
	hands_overlay.show()

	await FadeInOut.fade_out()

	animation_player.play("brothers_view")
	await get_tree().create_timer(3).timeout
	DialogueManager.show_dialogue_balloon(dialogue_res, "francisco")
