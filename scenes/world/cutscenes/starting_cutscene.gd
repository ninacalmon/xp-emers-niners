extends Node
class_name StartingCutscene


signal next

@export_group("Characters")
@export var player: Player
@export var julio: Node3D
@export var lucio: Node3D
@export var hugo: Node3D
@export var sanson: Node3D
@export var prior: Node3D

@export_group("Scene")
@export var camera: Camera3D
@export var hands_overlay: HandsOverlay

@export_group("Animation Speeds")
@export var altar_speed: float = 0.2
@export var sun_speed: float = 0.03
@export var monks_speed: float = 0.2

@onready var sanson_pos: Marker3D = $SansonPos
@onready var julio_pos: Marker3D = $JulioPos
@onready var hugo_pos: Marker3D = $HugoPos
@onready var prior_pos: Marker3D = $PriorPos
@onready var player_pos: Marker3D = $PlayerPos

@onready var animation_player: AnimationPlayer = %StartingAnimationPlayer

var dialogue_res = preload("uid://dhu5fv6qml7oi")

var is_francisco_talking: bool = false
var balloon: DialogueManagerExampleBalloon
var seconds_per_step


func _ready() -> void:
	hands_overlay = get_tree().get_first_node_in_group("hands_overlay")


func play_cutscene() -> void:
	hands_overlay.hide()
	player.is_cutscene_locked = true
	position_starting_cutscene()
	camera_starting_cutscene()
	start_anim_starting_cutscene()


func position_starting_cutscene() -> void:
	sanson.global_position = sanson_pos.global_position
	julio.global_position = julio_pos.global_position
	hugo.global_position = hugo_pos.global_position
	prior.global_position = prior_pos.global_position
	player.global_position = player_pos.global_position


func camera_starting_cutscene() -> void:
	#camera.fov = 40.0
	pass


func start_anim_starting_cutscene() -> void:
	animation_player.speed_scale = altar_speed
	animation_player.play("altar")
	await animation_player.animation_finished

	animation_player.speed_scale = sun_speed
	animation_player.play("sun")

	await get_tree().create_timer(2).timeout

	balloon = DialogueManager.show_dialogue_balloon(dialogue_res, "sun")
	await balloon.ready
	seconds_per_step = balloon.dialogue_label.seconds_per_step
	balloon.dialogue_label.seconds_per_step = 0.08

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	await next

	animation_player.speed_scale = monks_speed
	animation_player.play("monks")
	await animation_player.animation_finished
	animation_player.play_backwards("monks")
	animation_player.pause()

	#await get_tree().create_timer(3).timeout
	DialogueManager.show_dialogue_balloon(dialogue_res, "francisco")


func _on_dialogue_ended(_res: DialogueResource):
	#if is_francisco_talking:
		#await get_tree().create_timer(1.0).timeout
		#return await FadeInOut.change_scene_to("res://scenes/world/world.tscn")

	#is_francisco_talking = true
	balloon.dialogue_label.seconds_per_step = seconds_per_step
	next.emit()

	#animation_player.stop()
#
	#await FadeInOut.fade_in()
	#phantom_camera_sun_view.priority = 0
	#camera_3d.fov = 75.0
	#hands_overlay.show()
#
	#await FadeInOut.fade_out()
#
	#animation_player.play("brothers_view")
	#await get_tree().create_timer(3).timeout
	#DialogueManager.show_dialogue_balloon(dialogue_res, "francisco")
