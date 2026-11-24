extends Node3D
class_name EndingCutscene

signal finished

@export var skip_cutscene: bool = false
@onready var game_ui_overlay: CanvasLayer = $"../../VisualConfig/GameUiOverlay"

@export_group("Characters")
@export var player: Player
@export var julio: Node3D
@export var hugo: Node3D
@export var sanson: Node3D
@export var prior: Node3D
@export var abbott: Abbott

@export_group("Scene")
@export var abbots_door: DoubleDoorAction
@export var camera: Camera3D
@export var dialogue_res: DialogueResource
@export var fire: PackedScene
@export var fire_markers: Array[Marker3D] = []
@export var world_environment: WorldEnvironment

@export_group("Animation Speeds")
@export var zoom_in_speed: float = 0.2
@export var walk_to_window_speed: float = 0.2
@export var window_view_speed: float = 0.2
@export var faces_speed: float = 0.2
@export var back_fire_speed: float = 0.2
@export var curtains_fire_speed: float = 0.2
@export var zoom_out_fire_speed: float = 0.2
@export var sanson_fire_speed: float = 0.2
@export var julio_fire_speed: float = 0.2
@export var hugo_fire_speed: float = 0.2
@export var monastery_fire_speed: float = 0.1

@export_group("Abbott")
@export var abbott_approach_duration: float = 4.0

@export_group("Fire")
@export var fire_spawn_stagger: float = 0.25
@export var fire_grow_duration: float = 1.5
@export var fire_rise_height: float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_detection: Area3D = $PlayerDetection

@onready var abbott_pos: Marker3D = $AbbottPos
@onready var abbott_near_pos: Marker3D = $AbbottNearPos
@onready var sanson_pos: Marker3D = $SansonPos
@onready var hugo_pos: Marker3D = $HugoPos
@onready var julio_pos: Marker3D = $JulioPos
@onready var prior_pos: Marker3D = $PriorPos

#@onready var abbott_music: AudioStreamPlayer = $AbbottMusic
#@onready var fire_ending_music: AudioStreamPlayer = $FireEndingMusic
#@onready var fire_markers_group: Node3D = $FireMarkers
@export var music_ending_fire: AudioStreamPlayer
@export var music_ending_melt: AudioStreamPlayer
@onready var music_ending_endfire: AudioStreamPlayer = $MusicEndingENDFIRE
@onready var music_ending_endmelt: AudioStreamPlayer = $MusicEndingENDMELT

var started: bool = false
var spawned_fires: Array[Node3D] = []

#@onready var smoke: Node3D = %Smoke
#@onready var fire_1: Node3D = $Fire
#@onready var fire_2: Node3D = $Fire2
#@export var big_fire: Node3D

func _ready() -> void:
	if skip_cutscene:
		return

	abbots_door.opening.connect(_on_abbots_door_opening)
	player_detection.body_entered.connect(_on_player_entered)

	CharacterData.Sanson.flower_got = true
	abbots_door.open_door()

	#for i in fire_markers_group.get_children():
		#if i is Marker3D:
			#fire_markers.append(i)

	#fire_1.static_flame.emitting = false
	#fire_1.flames.emitting = false
	#fire_1.smoke.emitting = false
	#fire_1.particles_floating.emitting = false
	#fire_2.static_flame.emitting = false
	#fire_2.flames.emitting = false
	#fire_2.smoke.emitting = false
	#fire_2.particles_floating.emitting = false



func _on_abbots_door_opening() -> void:
	await get_tree().process_frame
	abbott.position = Vector3.ZERO
	abbott.global_position = abbott_pos.global_position
	DialogueData.set_mood("Abade", DialogueData.AbbottsMoods.idle)
	abbott.sprite_3d.modulate = Color.BLACK
	abbott.pendulum_animated_sprite.modulate = Color.BLACK


func _on_player_entered(body: Node3D) -> void:
	if not body is Player or started:
		return

	started = true
	play_cutscene()


func play_cutscene() -> void:
	# The hands overlay is intentionally NOT hidden.
	player.is_cutscene_locked = true
	_position_characters()

	# --- Abbott appears ---
	#abbott_music.play()
	if CharacterData.Sanson.flower_got:
		AudioManager.play_music(music_ending_fire)
	else:
		AudioManager.play_music(music_ending_melt)
	_tween_abbott_closer()
	await _play_animation("zoom_in", zoom_in_speed)
	var oldsky = world_environment.environment.sky
	world_environment.environment.sky = null
	camera.cull_mask = 1 << 17
	if CharacterData.Sanson.flower_got:
		await _run_dialogue("abbott", true)
		#smoke.smoke.emitting = true
		await _run_dialogue("fire_start", true)
		AudioManager.play_music(music_ending_endfire)
		#smoke.particles_floating.emitting = true
		#fire_1.static_flame.emitting = true
		#fire_1.flames.emitting = true
		#fire_1.smoke.emitting = true
		#fire_1.particles_floating.emitting = true
		#fire_2.static_flame.emitting = true
		#fire_2.flames.emitting = true
		#fire_2.smoke.emitting = true
		#fire_2.particles_floating.emitting = true
		await _run_dialogue("fire", true)
	else:
		AudioManager.play_music(music_ending_endmelt)
		await _run_dialogue("happy_ending", true)

	#await get_tree().create_timer(2).timeout
	#await FadeInOut.fade_in(2)
	#game_ui_overlay.hide()
	#world_environment.environment.sky = oldsky
	#big_fire.show()
	#camera.cull_mask = 0xFFFFF
	#FadeInOut.fade_out(1)
	#await _play_animation("monastery_far", zoom_in_speed)
	await FadeInOut.fade_in(3)
	LoadingManager.load_scene("res://scenes/interface/main_menu/main_menu.tscn")

	#var tween = create_tween()
	#tween.tween_property(world_environment.environment)

	## --- First dialogue (waits for it) ---
	#await _run_dialogue("abbott", true)
#
	## --- Window sequence ---
	#await _play_animation("walk_to_window", walk_to_window_speed)
	#await _play_animation("window_view", window_view_speed)
	##await _play_animation("faces", faces_speed)
	#await FadeInOut.fade_in(1)
	#_run_dialogue("fire", true)
#
	## --- Fire begins ---
	#_spawn_fires()
	##await _play_animation("back_fire", back_fire_speed)
#
	## Dialogue that does NOT block the cutscene
	##_run_dialogue("fire", false)
	##fire_ending_music.play()
#
	#await _play_animation("curtains_fire", curtains_fire_speed)
	#await _play_animation("zoom_out_fire", zoom_out_fire_speed)
	#await _play_animation("sanson_fire", sanson_fire_speed)
	#await _play_animation("julio_fire", julio_fire_speed)
	#await _play_animation("hugo_fire", hugo_fire_speed)
	#await _play_animation("monastery_fire", monastery_fire_speed)
#
	## No state restoration: this is the end of the game.
	#finished.emit()
	# TODO: await FadeInOut.fade_in(2.0) and go to credits / main menu


func _position_characters() -> void:
	sanson.global_position = sanson_pos.global_position
	hugo.global_position = hugo_pos.global_position
	julio.global_position = julio_pos.global_position
	prior.global_position = prior_pos.global_position

	# Keep them from reacting to the player during the cutscene
	sanson.set("is_chatting", true)
	hugo.set("is_chatting", true)
	julio.set("is_chatting", true)
	prior.set("is_chatting", true)


func _tween_abbott_closer() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(abbott, "global_position", abbott_near_pos.global_position, abbott_approach_duration)
	tween.tween_property(abbott.sprite_3d, "modulate", Color.WHITE, abbott_approach_duration)
	tween.tween_property(abbott.pendulum_animated_sprite, "modulate", Color.WHITE, abbott_approach_duration)


func _spawn_fires() -> void:
	for marker: Marker3D in fire_markers:
		var fire_instance: Node3D = fire.instantiate() as Node3D
		add_child(fire_instance)
		spawned_fires.append(fire_instance)

		var target_pos: Vector3 = marker.global_position
		fire_instance.global_position = target_pos + Vector3.DOWN * fire_rise_height
		fire_instance.scale = Vector3.ZERO

		var tween: Tween = create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(fire_instance, "global_position", target_pos, fire_grow_duration)
		tween.tween_property(fire_instance, "scale", Vector3.ONE, fire_grow_duration)

		await get_tree().create_timer(fire_spawn_stagger).timeout


func _play_animation(anim_name: StringName, speed: float) -> void:
	animation_player.speed_scale = speed
	animation_player.play(anim_name)
	await animation_player.animation_finished


func _run_dialogue(title: String, wait: bool) -> void:
	var balloon: DialogueManagerExampleBalloon = DialogueManager.show_dialogue_balloon(dialogue_res, title)
	await balloon.ready
	if wait:
		await DialogueManager.dialogue_ended
