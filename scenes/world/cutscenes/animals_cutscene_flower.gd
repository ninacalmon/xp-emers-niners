extends Node
class_name AnimalsCutscene

signal finished

enum Variant { INK, PLANT }

@export var variant: Variant = Variant.INK

@export var skip_cutscene: bool = false

@export_group("Characters")
@export var player: Player
@export var julio: Node3D
@export var hugo: DialogueAction
@export var sheep: Sheep
@export var sheep_2: Sheep
@export var sheep_3: Sheep
@export var sheep_rotten: ActionTrigger
@export var barn_door: OpenDoorAction

@export_group("Positions")
@export var sheep_pos: Marker3D
@export var sheep_pos_2: Marker3D
@export var sheep_pos_3: Marker3D
@export var sheep_rotten_pos: Marker3D
@export var julio_pos: Marker3D
@export var julio_pos_after: Marker3D
@export var player_pos_after: Marker3D
@export var julio_pos_after_plant: Marker3D
@export var hugo_pos_after: Marker3D


@export_group("Cameras")
@export var camera: Camera3D
@export var barn_camera: PhantomCamera3D
@export var sky_camera: PhantomCamera3D
@export var julio_camera: PhantomCamera3D

@export_group("Animation")
@export var animation_player: AnimationPlayer
@export var barn_zoom_out_speed: float = 0.07
@export var julio_face_speed: float = 0.17
@export var sky_speed: float = 0.1

@export_group("Dialogue")
## Time (in animation seconds, ignoring speed_scale) into barn_zoom_out when the dialogue starts.
@export var dialogue_start_time: float = 0.2
@export var dialogue_title: String = "start_flower"
@export var dialogue_title_plant: String = "start_plant"

@export_group("Audio")
@export var music: AudioStreamPlayer
#@export var sheep_audio: AudioStreamPlayer3D
@export var sheep_cry: AudioStreamPlayer

var dialogue_res: DialogueResource = preload("uid://cb7rb4i0sjyu6")

var started: bool = false
var _dialogue_active: bool = false
var balloon: DialogueManagerExampleBalloon

# Original state, saved right before the cutscene starts
var _orig_sheep_transform: Transform3D
var _orig_sheep_2_transform: Transform3D
var _orig_sheep_3_transform: Transform3D
var _orig_sheep_rotten_transform: Transform3D
var _orig_julio_transform: Transform3D
var _orig_player_transform: Transform3D
var _orig_camera_transform: Transform3D
var _orig_cull_mask: int
var _orig_speed_scale: float
var _orig_hands_visible: bool
var _orig_dialogue_text_modulate: Color

var hands_overlay: HandsOverlay
@export var dialogue_input_text: RichTextLabel

var plant_julio_is_away

func _ready() -> void:
	hands_overlay = get_tree().get_first_node_in_group("hands_overlay") as HandsOverlay

	if skip_cutscene:
		_skip_to_end_state()
		return




# ------------------------------------------------------------------ SAVE

func _save_original_state() -> void:
	_orig_sheep_transform = sheep.global_transform
	_orig_sheep_2_transform = sheep_2.global_transform
	_orig_sheep_3_transform = sheep_3.global_transform
	_orig_sheep_rotten_transform = sheep_rotten.global_transform
	_orig_julio_transform = julio.global_transform
	_orig_player_transform = player.global_transform
	_orig_camera_transform = camera.transform
	_orig_cull_mask = camera.cull_mask
	_orig_speed_scale = animation_player.speed_scale
	_orig_hands_visible = hands_overlay.visible
	_orig_dialogue_text_modulate = dialogue_input_text.modulate


# ------------------------------------------------------------------ SETUP

func play_cutscene() -> void:
	julio.sprite_3d.shaded = false
	player.is_cutscene_locked = true
	await FadeInOut.fade_in(1.0)
	_save_original_state()

	hands_overlay.hide()
	dialogue_input_text.modulate = Color.TRANSPARENT

	_position_cutscene()
	_setup_cameras()
	_start_audio()

	AudioManager.play_music(music)
	FadeInOut.fade_out(1.0)
	await _run_animations()

	# Black screen while everything is restored/moved
	await FadeInOut.fade_in(3.0)
	end_cutscene()
	await FadeInOut.fade_out(3.0)
	finished.emit()

	#if variant == Variant.PLANT:
		#balloon = DialogueManager.show_dialogue_balloon(dialogue_res, "plant_thanks")


func _position_cutscene() -> void:
	sheep.global_position = sheep_pos.global_position
	sheep_2.global_position = sheep_pos_2.global_position
	sheep_3.global_position = sheep_pos_3.global_position
	sheep_rotten.global_position = sheep_rotten_pos.global_position
	julio.global_position = julio_pos.global_position
	_set_julio_mood(DialogueData.JulioMoods.animals)


func _setup_cameras() -> void:
	sky_camera.priority = 0
	julio_camera.priority = 0
	barn_camera.priority = 20


func _start_audio() -> void:
	pass
	#sheep_audio.play()


# ------------------------------------------------------------------ SEQUENCE

func _run_animations() -> void:
	# 1) barn_zoom_out (dialogue starts midway)
	animation_player.speed_scale = barn_zoom_out_speed
	animation_player.play("barn_zoom_out")
	_start_dialogue_after_delay()
	await animation_player.animation_finished

		# 2) julio_face
	barn_camera.priority = 0
	julio_camera.priority = 20
	animation_player.speed_scale = julio_face_speed
	_set_julio_mood(_get_julio_face_mood())
	animation_player.play("julio_face")
	if variant == Variant.INK:
		AudioManager.play_sound(sheep_cry, 10)
	await animation_player.animation_finished

	# 3) sky
	julio_camera.priority = 0
	sky_camera.priority = 20
	animation_player.speed_scale = sky_speed

	for shp: Sheep in get_tree().get_nodes_in_group("sheep"):
		if variant == Variant.INK:
			shp.die(Sheep.Poison.INK)
		else:
			shp.die(Sheep.Poison.PLANT)

	animation_player.play("sky")

	if variant == Variant.INK:
		await get_tree().create_timer((1 / sky_speed) / 1.5).timeout
		AudioManager.stop_sound(sheep_cry, 6.0)

	await animation_player.animation_finished

	# Don't end the cutscene while the dialogue is still running
	if _dialogue_active:
		await DialogueManager.dialogue_ended


func _start_dialogue_after_delay() -> void:
	# Animation time -> real time (accounts for speed_scale)
	var delay: float = dialogue_start_time / maxf(animation_player.speed_scale, 0.001)
	await get_tree().create_timer(delay).timeout

	_dialogue_active = true
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)

	# Julio poses when the dialogue starts
	#_set_julio_mood(DialogueData.JulioMoods.animals)

	balloon = DialogueManager.show_dialogue_balloon(dialogue_res, _get_dialogue_title())
	await balloon.ready
	balloon.set_skip_blocked(true)
	balloon.set_auto_advance(true, 2.5)


func _on_dialogue_ended(_res: DialogueResource) -> void:
	_dialogue_active = false
	#_set_julio_mood(DialogueData.JulioMoods.idle)


func _set_julio_mood(mood: DialogueData.JulioMoods) -> void:
	DialogueData.set_mood("Julio", mood, true, true)


func _get_dialogue_title() -> String:
	if variant == Variant.PLANT:
		return dialogue_title_plant
	return dialogue_title


func _get_julio_pos_after() -> Marker3D:
	if variant == Variant.PLANT:
		return julio_pos_after_plant
	return julio_pos_after


func _get_julio_face_mood() -> DialogueData.JulioMoods:
	match variant:
		Variant.PLANT:
			return DialogueData.JulioMoods.INTENSE_HAPPY
		_:
			return DialogueData.JulioMoods.IDLE_CRY

# ------------------------------------------------------------------ END

func end_cutscene() -> void:
	AudioManager.stop_music()
	WorldStateManager.barn_cutscene_played = true

	# Animation
	julio.sprite_3d.shaded = true
	_set_julio_mood(DialogueData.JulioMoods.idle)
	animation_player.stop()
	animation_player.speed_scale = _orig_speed_scale
	barn_door.locked = false
	barn_door.open_door()

	# Cameras
	barn_camera.priority = 0
	sky_camera.priority = 0
	julio_camera.priority = 0
	camera.cull_mask = _orig_cull_mask
	camera.transform = _orig_camera_transform

	# Audio
	#sheep_audio.stop()

	# UI
	dialogue_input_text.modulate = _orig_dialogue_text_modulate
	hands_overlay.visible = _orig_hands_visible

	# REVERT to original
	sheep.global_transform = _orig_sheep_transform
	sheep_2.global_transform = _orig_sheep_2_transform
	sheep_3.global_transform = _orig_sheep_3_transform
	sheep_rotten.global_transform = _orig_sheep_rotten_transform

	# AFTER positions
	julio.global_position = _get_julio_pos_after().global_position
	hugo.global_position = hugo_pos_after.global_position
	player.global_transform = player_pos_after.global_transform
	_set_julio_mood(DialogueData.JulioMoods.idle)

	player.is_cutscene_locked = false
	TimeManager.set_time(TimeManager.Times.at1800)


func _skip_to_end_state() -> void:
	started = true
	WorldStateManager.barn_cutscene_played = true

	await get_tree().process_frame

	barn_camera.priority = 0
	sky_camera.priority = 0
	julio_camera.priority = 0
	camera.make_current()

	julio.global_position = _get_julio_pos_after().global_position
	_set_julio_mood(DialogueData.JulioMoods.idle)
	# Player and sheep are intentionally left untouched.
