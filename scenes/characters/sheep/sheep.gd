
class_name Sheep
extends Node3D

enum Poison {PLANT, INK}

@export var anim: SpriteFrames

@export_group("Movement")
@export var movement_range: float = 0.3
@export var movement_speed: float = 0.3
@export var idle_time_min: float = 4.0
@export var idle_time_max: float = 10.0

@export_group("Bounce")
@export var bounce_duration: float = 0.08
@export_range(0.0, 0.5, 0.01) var bounce_amount: float = 0.025

@export_group("Audio")
@export var audio_interval_min: float = 3.0
@export var audio_interval_max: float = 8.0


@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var b_eeeh_audio_stream_player_3d: AudioStreamPlayer3D = $bEEEHAudioStreamPlayer3D

var is_dead: bool = false
var original_position: Vector3
var original_sprite_scale: Vector3


func _ready() -> void:
	animated_sprite_3d.sprite_frames = anim
	animated_sprite_3d.play("living")

	original_position = position
	original_sprite_scale = animated_sprite_3d.scale

	roam()
	randomize_bleats()


func roam() -> void:
	while not is_dead:
		await get_tree().create_timer(randf_range(idle_time_min, idle_time_max)).timeout

		if is_dead:
			break

		var direction: float = [-1.0, 1.0].pick_random()
		var distance: float = randf_range(0.05, movement_range)

		var target_x: float = clampf(
			position.x + direction * distance,
			original_position.x - movement_range,
			original_position.x + movement_range
		)

		var actual_direction: float = signf(target_x - position.x)

		if actual_direction == 0.0:
			continue

		animated_sprite_3d.flip_h = actual_direction > 0.0

		bounce_on_it()

		var walk_tween: Tween = create_tween()
		walk_tween.tween_property(
			self,
			"position:x",
			target_x,
			absf(target_x - position.x) / movement_speed
		).set_trans(Tween.TRANS_LINEAR)

		await walk_tween.finished


func bounce_on_it() -> void:
	var tall_scale: Vector3 = Vector3(
		original_sprite_scale.x * (1.0 - bounce_amount),
		original_sprite_scale.y * (1.0 + bounce_amount),
		original_sprite_scale.z
	)

	var short_scale: Vector3 = Vector3(
		original_sprite_scale.x * (1.0 + bounce_amount),
		original_sprite_scale.y * (1.0 - bounce_amount),
		original_sprite_scale.z
	)

	var bounce_tween: Tween = create_tween()
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(animated_sprite_3d, "scale", tall_scale, bounce_duration)
	bounce_tween.tween_property(animated_sprite_3d, "scale", short_scale, bounce_duration)
	bounce_tween.tween_property(animated_sprite_3d, "scale", original_sprite_scale, bounce_duration)


func die(poison: Poison) -> void:
	if is_dead:
		return

	is_dead = true
	b_eeeh_audio_stream_player_3d.stop()

	match poison:
		Poison.PLANT:
			animated_sprite_3d.play("dead_plant")
		Poison.INK:
			animated_sprite_3d.play("dead_ink")


func randomize_bleats() -> void:
	while not is_dead:
		await get_tree().create_timer(
			randf_range(audio_interval_min, audio_interval_max)
		).timeout

		if is_dead:
			break

		b_eeeh_audio_stream_player_3d.play()
