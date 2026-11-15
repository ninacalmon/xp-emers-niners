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
@export var dialogue_input_text: RichTextLabel
@export var bell_audio_stream_player_3d: AudioStreamPlayer3D
@export var bell_audio_stream_player_3d_2: AudioStreamPlayer3D
@export var ambient: AudioStreamPlayer



@export var world_environment: WorldEnvironment

@export_group("Animation Speeds")
@export var altar_speed: float = 0.2
@export var sun_speed: float = 0.03
@export var monks_speed: float = 0.2
@export var close_ups_speed: float = 0.2
@export var altar_far_speed: float = 0.08
@export var outside_speed: float = 0.1

@onready var sanson_pos: Marker3D = $SansonPos
@onready var julio_pos: Marker3D = $JulioPos
@onready var hugo_pos: Marker3D = $HugoPos
@onready var prior_pos: Marker3D = $PriorPos
@onready var player_pos: Marker3D = $PlayerPos

@onready var animation_player: AnimationPlayer = %StartingAnimationPlayer
@onready var name_label: RichTextLabel = $NameLabel
@onready var music: AudioStreamPlayer = $Music

var dialogue_res = preload("uid://dhu5fv6qml7oi")

var is_sun: bool = true
var balloon: DialogueManagerExampleBalloon
var seconds_per_step


func _ready() -> void:
	hands_overlay = get_tree().get_first_node_in_group("hands_overlay")
	name_label.hide()


func play_cutscene() -> void:
	music.play()
	hands_overlay.hide()
	#game_ui_overlay.hide()
	dialogue_input_text.hide()
	player.is_cutscene_locked = true
	position_starting_cutscene()
	scene_starting_cutscene()
	start_anim_starting_cutscene()



func position_starting_cutscene() -> void:
	sanson.global_position = sanson_pos.global_position
	julio.global_position = julio_pos.global_position
	hugo.global_position = hugo_pos.global_position
	prior.global_position = prior_pos.global_position
	player.global_position = player_pos.global_position


func scene_starting_cutscene() -> void:
	#camera.fov = 40.0
	#world_environment.environment.glow_intensity = 0.7
	world_environment.environment.glow_strength = 1.5
	world_environment.environment.glow_bloom = 0.6
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
	balloon.dialogue_label.seconds_per_step = 0.06
	balloon.set_skip_blocked(true)
	balloon.set_auto_advance(true, 1.6)

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	#await get_tree().create_timer(5).timeout
	bell_audio_stream_player_3d.play()
	await get_tree().create_timer(9).timeout
	bell_audio_stream_player_3d.play()
	#TimeManager.set_time_starting_cutscene()

	await next

	animation_player.speed_scale = monks_speed
	animation_player.play("monks")
	bell_audio_stream_player_3d.play()
	await animation_player.animation_finished


	await get_tree().create_timer(0.6).timeout
	balloon = DialogueManager.show_dialogue_balloon(dialogue_res, "francisco")
	await balloon.ready
	balloon.dialogue_label.seconds_per_step = 0.045
	balloon.set_skip_blocked(true)
	balloon.set_auto_advance(true, 1.8)

	await get_tree().create_timer(4).timeout
	bell_audio_stream_player_3d.play()

	await next

	animation_player.speed_scale = close_ups_speed
	$CloseUpCamera.follow_target = sanson
	$CloseUpCamera.look_at_target = sanson

	var step: float = 1.00 / close_ups_speed
	animation_player.play("close_up")
	bell_audio_stream_player_3d_2.play()
	#await animation_player.
	await get_tree().create_timer(step).timeout
	$CloseUpCamera.follow_target = julio
	$CloseUpCamera.look_at_target = julio
	bell_audio_stream_player_3d.play()
	await get_tree().create_timer(step).timeout
	$CloseUpCamera.follow_target = hugo
	$CloseUpCamera.look_at_target = hugo
	bell_audio_stream_player_3d_2.play()
	await animation_player.animation_finished
	print("finished")

	animation_player.speed_scale = altar_far_speed
	animation_player.play("altar_far")
	bell_audio_stream_player_3d.play()
	await animation_player.animation_finished

	animation_player.speed_scale = outside_speed
	animation_player.play("outside")
	bell_audio_stream_player_3d.play()

	await get_tree().create_timer(4).timeout
	bell_audio_stream_player_3d.play()
	name_label.show()

	await animation_player.animation_finished

	await get_tree().create_timer(1).timeout
	FadeInOut.fade_in(0.5)
	#player.is_cutscene_locked = false


func _on_dialogue_ended(_res: DialogueResource):
	#if is_francisco_talking:
		#await get_tree().create_timer(1.0).timeout
		#return await FadeInOut.change_scene_to("res://scenes/world/world.tscn")

	#is_francisco_talking = true
	if is_sun:
		is_sun = false
		balloon.dialogue_label.seconds_per_step = seconds_per_step
		next.emit()
	else:
		next.emit()
		balloon.dialogue_label.seconds_per_step = seconds_per_step

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
