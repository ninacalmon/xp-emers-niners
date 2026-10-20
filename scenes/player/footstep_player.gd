class_name FootstepPlayer
extends Node

## footstep intervals in seconds
@export var walk_interval: float = 0.5
@export var run_interval: float = 0.3
## speed (m/s) below which no footsteps play
@export var min_step_speed: float = 0.5
## how far below the character's origin to look for ground
@export var ground_check_length: float = 0.1

@onready var stone_audio_stream_player: AudioStreamPlayer = $StoneAudioStreamPlayer
@onready var dirt_audio_stream_player: AudioStreamPlayer = $DirtAudioStreamPlayer

var character: CharacterBody3D
var _step_timer: Timer

## maps a global group name to its stream player. keys MUST match global groups.
var footstep_stream_players: Dictionary = {}


func _ready() -> void:
	character = get_parent() as CharacterBody3D
	if character == null:
		push_error("Footsteps node must be a child of a CharacterBody3D")
		return

	footstep_stream_players = {
		"stone_floor": stone_audio_stream_player,
		"dirt_floor": dirt_audio_stream_player,
	}

	_step_timer = Timer.new()
	_step_timer.one_shot = true
	add_child(_step_timer)


func _physics_process(_delta: float) -> void:
	var horizontal_speed: float = Vector2(character.velocity.x, character.velocity.z).length()
	var moving_on_ground: bool = character.is_on_floor() and horizontal_speed > min_step_speed

	if not moving_on_ground:
		_step_timer.stop()
		return

	if _step_timer.is_stopped():
		_play_footstep()
		var interval: float = run_interval if Input.is_action_pressed("run") else walk_interval
		_step_timer.start(interval)


func _get_ground_collider() -> Node:
	# Only valid inside _physics_process
	var space := character.get_world_3d().direct_space_state
	var from := character.global_position
	var to := from + Vector3.DOWN * ground_check_length

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [character.get_rid()]

	var result := space.intersect_ray(query)
	if result.is_empty():
		return null
	return result.collider as Node


func _get_ground_group() -> String:
	var collider := _get_ground_collider()
	if collider == null:
		return ""

	for group_name in footstep_stream_players.keys():
		if collider.is_in_group(group_name):
			return group_name
	return ""


func _play_footstep() -> void:
	var group: String = _get_ground_group()
	if group == "" or not footstep_stream_players.has(group):
		return

	var stream_player: AudioStreamPlayer = footstep_stream_players[group]
	if stream_player == null:
		return

	stream_player.play()
