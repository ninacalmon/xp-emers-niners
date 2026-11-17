extends Node
class_name StartingCutscene


signal next

@export var skip_cutscene: bool = false

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
@export var altar_far_speed: float = 0.1
@export var outside_speed: float = 0.1

@onready var sanson_pos: Marker3D = $SansonPos
@onready var julio_pos: Marker3D = $JulioPos
@onready var hugo_pos: Marker3D = $HugoPos
@onready var prior_pos: Marker3D = $PriorPos
@onready var player_pos: Marker3D = $PlayerPos


@onready var af_julio_pos: Marker3D = $AfterPositions/AfJulioPos
@onready var af_hugo_pos: Marker3D = $AfterPositions/AfHugoPos
@onready var af_sanson_pos: Marker3D = $AfterPositions/AfSansonPos
@onready var af_prior_pos: Marker3D = $AfterPositions/AfPriorPos


@onready var animation_player: AnimationPlayer = %StartingAnimationPlayer
@onready var name_label: RichTextLabel = $NameLabel
@onready var music: AudioStreamPlayer = $Music
@onready var player_detection: Area3D = $PlayerDetection

var _orig_glow_strength: float
var _orig_glow_bloom: float
var _orig_cull_mask: int
var _orig_speed_scale: float
var _orig_bell_volume_db: float
var _orig_hands_visible: bool
var _orig_camera_transform: Transform3D
var _orig_player_transform: Transform3D

var dialogue_res = preload("uid://dhu5fv6qml7oi")

var is_sun: bool = true
var balloon: DialogueManagerExampleBalloon
var seconds_per_step

var started: bool = false

func _ready() -> void:
	hands_overlay = get_tree().get_first_node_in_group("hands_overlay") as HandsOverlay
	name_label.hide()

	if skip_cutscene:
		_skip_to_end_state()
		return

	sanson.global_position = sanson_pos.global_position
	julio.global_position = julio_pos.global_position
	hugo.global_position = hugo_pos.global_position
	prior.global_position = prior_pos.global_position

	player_detection.body_entered.connect(_on_player_entered)

	await get_tree().create_timer(2).timeout
	TaskManager.give_task("noon_prayer", "Se dirija ao Altar para a oração de meio dia.")
	

func _save_original_state() -> void:
	_orig_glow_strength = world_environment.environment.glow_strength
	_orig_glow_bloom = world_environment.environment.glow_bloom
	_orig_cull_mask = camera.cull_mask
	_orig_speed_scale = animation_player.speed_scale
	_orig_bell_volume_db = bell_audio_stream_player_3d.volume_db
	_orig_hands_visible = hands_overlay.visible
	_orig_camera_transform = camera.transform
	_orig_player_transform = player.global_transform


func play_cutscene() -> void:
	TaskManager.complete_task("noon_prayer")
	player.is_cutscene_locked = true
	await FadeInOut.fade_in(1.5)
	await  get_tree().create_timer(2).timeout
	_save_original_state()
	music.play()
	hands_overlay.hide()
	#game_ui_overlay.hide()
	dialogue_input_text.modulate = Color.TRANSPARENT
	position_starting_cutscene()
	scene_starting_cutscene()
	start_anim_starting_cutscene()
	FadeInOut.fade_out(1)



func position_starting_cutscene() -> void:
	sanson.global_position = sanson_pos.global_position
	julio.global_position = julio_pos.global_position
	hugo.global_position = hugo_pos.global_position
	prior.global_position = prior_pos.global_position
	player.global_position = player_pos.global_position


func scene_starting_cutscene() -> void:
	#camera.fov = 40.0
	#world_environment.environment.glow_intensity = 0.7
	world_environment.environment.glow_strength = 1.3
	world_environment.environment.glow_bloom = 0.5
	pass


func start_anim_starting_cutscene() -> void:
	camera.set_cull_mask_value(6, true)
	DialogueData.set_mood("Julio", DialogueData.JulioMoods.back, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.back, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.back, true, true)

	animation_player.speed_scale = altar_speed
	animation_player.play("altar")
	bell_audio_stream_player_3d_2.play()
	await animation_player.animation_finished
	camera.set_cull_mask_value(6, false)

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

	DialogueData.set_mood("Julio", DialogueData.JulioMoods.idle, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.idle, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.idle, true, true)

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

	await get_tree().create_timer(4.3).timeout
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
	camera.set_cull_mask_value(6, true)

	DialogueData.set_mood("Julio", DialogueData.JulioMoods.back, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.back, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.back, true, true)

	animation_player.play("altar_far")
	bell_audio_stream_player_3d.play()
	await animation_player.animation_finished
	camera.set_cull_mask_value(6, false)

	animation_player.speed_scale = outside_speed
	animation_player.play("outside")
	bell_audio_stream_player_3d.play()

	DialogueData.set_mood("Julio", DialogueData.JulioMoods.idle, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.idle, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.idle, true, true)

	await get_tree().create_timer(5).timeout
	bell_audio_stream_player_3d.volume_db += 100
	bell_audio_stream_player_3d.play()
	bell_audio_stream_player_3d_2.play()
	name_label.show()

	await animation_player.animation_finished

	#await get_tree().create_timer(3).timeout
	await FadeInOut.fade_in(0.5)   # screen goes black while we restore everything
	end_cutscene()
	await FadeInOut.fade_out(1)    # reveal the normal world


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

func end_cutscene() -> void:
	WorldStateManager.starting_cutscene_played = true
	$OutsideCamera.priority = 0
	# Stop listening to dialogues (otherwise this fires on EVERY future dialogue)
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

	# Animation
	animation_player.stop()
	animation_player.speed_scale = _orig_speed_scale
	

	# Camera
	camera.cull_mask = _orig_cull_mask
	camera.transform = _orig_camera_transform
	camera.make_current()

	for pcam: PhantomCamera3D in _get_cutscene_pcams():
		pcam.priority = 0
	camera.cull_mask = _orig_cull_mask

	# Environment
	world_environment.environment.glow_strength = _orig_glow_strength
	world_environment.environment.glow_bloom = _orig_glow_bloom

	# Audio
	music.stop()
	bell_audio_stream_player_3d.stop()
	bell_audio_stream_player_3d_2.stop()
	bell_audio_stream_player_3d.volume_db = _orig_bell_volume_db

	# UI
	name_label.hide()
	dialogue_input_text.modulate = Color.WHITE
	hands_overlay.visible = _orig_hands_visible

	# Characters' moods
	DialogueData.set_mood("Julio", DialogueData.JulioMoods.idle, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.idle, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.idle, true, true)

	# Player
	player.global_transform = player_pos.global_transform
	player.is_cutscene_locked = false

	set_start_game_state()


func _on_player_entered(body: Node3D):
	print("ENTEREDDDD")
	if not body is Player or started:
		return

	started = true
	play_cutscene()


func _get_cutscene_pcams() -> Array[PhantomCamera3D]:
	var result: Array[PhantomCamera3D] = []
	for node: Node in find_children("*", "PhantomCamera3D", true, false):
		result.append(node as PhantomCamera3D)
	return result


func set_start_game_state():
	# Julio
	julio.global_position = af_julio_pos.global_position
	julio.brute_force_first_dialogue = true

	# Sanson
	sanson.global_position = af_sanson_pos.global_position
	sanson.is_chatting = true
	# Hugo
	hugo.global_position = af_hugo_pos.global_position
	hugo.is_chatting = true
	# Prior
	prior.global_position = af_prior_pos.global_position


func _skip_to_end_state() -> void:
	started = true
	WorldStateManager.starting_cutscene_played = true

	await get_tree().process_frame

	$OutsideCamera.priority = 0
	for pcam: PhantomCamera3D in _get_cutscene_pcams():
		pcam.priority = 0
	camera.make_current()

	DialogueData.set_mood("Julio", DialogueData.JulioMoods.idle, true, true)
	DialogueData.set_mood("Sanson", DialogueData.SansonMoods.idle, true, true)
	DialogueData.set_mood("Hugo", DialogueData.HugoMoods.idle, true, true)

	player.global_transform = player_pos.global_transform
	player.is_cutscene_locked = false
	set_start_game_state()
