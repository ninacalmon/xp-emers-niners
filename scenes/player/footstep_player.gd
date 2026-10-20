extends Node

@export var player: Player

@onready var stone_audio_stream_player: AudioStreamPlayer = $StoneAudioStreamPlayer
@onready var dirt_audio_stream_player: AudioStreamPlayer = $DirtAudioStreamPlayer

enum FloorTypes {STONE, DIRT}

func get_surface_type() -> FloorTypes:
	for i in player.get_slide_collision_count():
		var collision: KinematicCollision3D = player.get_slide_collision(i)
		# only consider surfaces that count as floor
		if collision.get_normal().dot(Vector3.UP) < cos(player.floor_max_angle):
			continue

		var collider = collision.get_collider()
		if collider is Node:
			if collider.is_in_group("stone_floor"):
				return FloorTypes.STONE

	return FloorTypes.DIRT

func play_sound():
	var stream_player: AudioStreamPlayer = dirt_audio_stream_player

	match get_surface_type():
		FloorTypes.STONE:
			stream_player = stone_audio_stream_player

	stream_player.play()
	await stream_player.finished




	#if collider is Node:
		#for surface in footstep_sounds.keys():
			#if collider.is_in_group(surface):
				#return surface
#
	#if collider.has_meta("surface"):
		#return collider.get_meta("surface")
#
	#return "default"
#
#func play_footstep() -> void:
	#var surface := get_surface_type()
	#if surface == "" or not footstep_sounds.has(surface):
		#return
	#footstep_player.stream = footstep_sounds[surface]
	#footstep_player.play()
