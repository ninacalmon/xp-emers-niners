class_name FootstepPlayer
extends Node

## footstep intervals in seconds
@export var walk_interval: float = 0.5
@export var run_interval: float = 0.3
## speed (m/s) below which no footsteps play
@export var min_step_speed: float = 0.5

@onready var hard_floor_audio_stream_player: AudioStreamPlayer = $HardFloorAudioStreamPlayer
@onready var dirt_floor_audio_stream_player: AudioStreamPlayer = $DirtFloorAudioStreamPlayer
@onready var current_stream_player: AudioStreamPlayer = dirt_floor_audio_stream_player

var character: CharacterBody3D
var _step_timer: Timer

var current_floor: StringName:
	set(value):
		current_floor = value
		change_step_sound()


func _ready() -> void:
	character = get_parent() as CharacterBody3D
	if character == null:
		push_error("FootstepPlayer must be a child of a CharacterBody3D")
		return

	_step_timer = Timer.new()
	_step_timer.one_shot = true
	add_child(_step_timer)

	for area: Area3D in get_tree().get_nodes_in_group("ground_areas"):
		area.body_entered.connect(_on_body_entered_ground_area.bind(area.name))

	current_floor = &"DirtFloor"


func _physics_process(_delta: float) -> void:
	if character == null:
		return

	var horizontal_speed: float = Vector2(character.velocity.x, character.velocity.z).length()
	var moving_on_ground: bool = character.is_on_floor() and horizontal_speed > min_step_speed

	if not moving_on_ground:
		_step_timer.stop()
		return

	if _step_timer.is_stopped():
		current_stream_player.play()
		var interval: float = run_interval if Input.is_action_pressed("run") else walk_interval
		_step_timer.start(interval)


func _on_body_entered_ground_area(body: Node3D, area_name: StringName) -> void:
	if not body is Player:
		return
	current_floor = area_name


func change_step_sound() -> void:
	print(current_floor)
	match current_floor:
		&"HardFloorNoEchoArea":
			hard_floor_echo(0)
		&"HardFloorLowEchoArea":
			hard_floor_echo(1)
		&"HardFloorMedEchoArea":
			hard_floor_echo(2)
		&"HardFloorHighEchoArea":
			hard_floor_echo(3)
		&"DirtFloor":
			dirt_floor()


func hard_floor_echo(idx: int) -> void:
	var bus: StringName = &"Sound Effects"

	match idx:
		1:
			bus = &"Sound Effects / LowEcho"
		2:
			bus = &"Sound Effects / MedEcho"
		3:
			bus = &"Sound Effects / HighEcho"

	hard_floor_audio_stream_player.bus = bus
	var bus_index: int = AudioServer.get_bus_index(bus)
	print("wanted bus: ", bus, " | index: ", bus_index, " | player bus: ", hard_floor_audio_stream_player.bus)
	current_stream_player = hard_floor_audio_stream_player


func dirt_floor() -> void:
	current_stream_player = dirt_floor_audio_stream_player

#class_name FootstepPlayer
#extends Node
#
### footstep intervals in seconds
#@export var walk_interval: float = 0.5
#@export var run_interval: float = 0.3
### speed (m/s) below which no footsteps play
#@export var min_step_speed: float = 0.5
### how far below the character's origin to look for ground
##@export var ground_check_length: float = 0.1
#
#@onready var hard_floor_audio_stream_player: AudioStreamPlayer = $HardFloorAudioStreamPlayer
#@onready var dirt_floor_audio_stream_player: AudioStreamPlayer = $DirtFloorAudioStreamPlayer
#
#
#var character: CharacterBody3D
#var _step_timer: Timer
#
#@onready var current_stream_player: AudioStreamPlayer = dirt_floor_audio_stream_player
#
#var current_floor: StringName:
	#set(value):
		#current_floor = value
		#change_step_sound
#
#
#func _ready() -> void:
	#character = get_parent() as CharacterBody3D
	#if character == null:
		#push_error("Footsteps node must be a child of a CharacterBody3D")
		#return
#
	#for area: Area3D in get_tree().get_nodes_in_group("ground_areas"):
		#area.body_entered.connect(_on_body_entered_ground_area.bind(area.name))
		##area.body_exited.connect(_on_body_exited_ground_area.bind(area.name))
#
	#current_floor = "DirtFloor"
#
#
#
#func _on_body_entered_ground_area(body: Node3D, area_name: StringName):
	#if not body is Player:
		#return
#
	#current_floor = area_name
#
#
#func change_step_sound():
	#match current_floor:
		#"HardFloorNoEchoArea": hard_floor_echo(0)
#
		#"HardFloorLowEchoArea": hard_floor_echo(1)
#
		#"HardFloorMedEchoArea": hard_floor_echo(2)
#
		#"HardFloorHighEchoArea": hard_floor_echo(3)
#
		#"DirtFloor": dirt_floor()
#
#
#func hard_floor_echo(idx: int):
	#var bus: StringName
#
	#match idx:
		#0:
			#bus = &"Sound Effects"
		#1:
			#bus = &"LowEcho"
		#2:
			#bus = &"MedEcho"
		#3:
			#bus = &"HighEcho"
	#
	#hard_floor_audio_stream_player.bus = bus
	#current_stream_player = hard_floor_audio_stream_player
#
#
#
#func dirt_floor():
	#current_stream_player = dirt_floor_audio_stream_player
#
#
#
##
	##footstep_stream_players = {
		##"stone_floor": stone_audio_stream_player,
		##"dirt_floor": dirt_audio_stream_player,
	##}
##
	##_step_timer = Timer.new()
	##_step_timer.one_shot = true
	##add_child(_step_timer)
##
##
##func _physics_process(_delta: float) -> void:
	##var horizontal_speed: float = Vector2(character.velocity.x, character.velocity.z).length()
	##var moving_on_ground: bool = character.is_on_floor() and horizontal_speed > min_step_speed
##
	##if not moving_on_ground:
		##_step_timer.stop()
		##return
##
	##if _step_timer.is_stopped():
		##_play_footstep()
		##var interval: float = run_interval if Input.is_action_pressed("run") else walk_interval
		##_step_timer.start(interval)
###
##
##func _get_ground_collider() -> Node:
	### Only valid inside _physics_process
	##var space := character.get_world_3d().direct_space_state
	##var from := character.global_position
	##var to := from + Vector3.DOWN * ground_check_length
##
	##var query := PhysicsRayQueryParameters3D.create(from, to)
	##query.exclude = [character.get_rid()]
##
	##var result := space.intersect_ray(query)
	##if result.is_empty():
		##return null
	##return result.collider as Node
##
##
##func _get_ground_group() -> String:
	##var collider := _get_ground_collider()
	##if collider == null:
		##return ""
##
	##for group_name in footstep_stream_players.keys():
		##if collider.is_in_group(group_name):
			##return group_name
	##return ""
##
##
##func _play_footstep() -> void:
	##var group: String = _get_ground_group()
	##if group == "" or not footstep_stream_players.has(group):
		##return
##
	##var stream_player: AudioStreamPlayer = footstep_stream_players[group]
	##if stream_player == null:
		##return
##
	##stream_player.play()
