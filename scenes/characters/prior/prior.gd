extends CharacterBody3D

@export var player_detection: Area3D
@export var player_outside_pos: Marker3D
@export var prior_bell_pos: Marker3D
@export var prior_hidden_pos: Marker3D
@export var bell_area_door: OpenDoorAction

@export var approach_speed_cutscene: float = 1.0
@export var stop_distance_cutscene: float = 1.3

@export var approach_speed: float = 2.0
@export var stop_distance: float = 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $SubViewportSprite/AnimatedSprite2D
@onready var dialogue_action: DialogueAction = $DialogueAction
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Player
var bell: ChurchBell
var _cutscene_started: bool = false
var _has_met_player: bool = false
var _start_transform: Transform3D
var is_bell_strike: bool = false


var is_disabled: bool = false

func _ready() -> void:
	_start_transform = global_transform
	player_detection.body_entered.connect(_on_body_entered_player_detec)

	bell = get_tree().get_first_node_in_group("bell")
	if bell:
		bell.bell_toll.connect(_on_bell_toll)


func _on_bell_toll() -> void:
	if is_disabled:
		return

	is_bell_strike = true

	global_position = prior_bell_pos.global_position
	player.is_cutscene_locked = true

	await player.look_at_target(global_position + Vector3(0, 1, 0), 1.0)
	await get_tree().create_timer(1.0).timeout

	_bell_strike()


func _on_body_entered_player_detec(body: Node3D) -> void:
	if is_disabled:
		return

	if _cutscene_started or not body is Player:
		return

	_cutscene_started = true
	player = body as Player

	start_cutscene()


func start_cutscene() -> void:
	if is_disabled:
		return

	bell_area_door.close_door()
	bell_area_door.locked = true

	player.is_cutscene_locked = true

	await player.look_at_target(global_position + Vector3(0, 1, 0), 1.0)

	if not _has_met_player:
		_has_met_player = true
		await _first_meeting()
	else:
		await _repeat_meeting()

	await get_tree().create_timer(0.5).timeout

	if is_bell_strike:
		return

	animated_sprite_2d.play("BELL_RUN")
	var reached: bool = await move_towards_target(approach_speed, stop_distance, player, true)

	if reached:
		await catch_player()


func _first_meeting():
	animated_sprite_2d.play("BELL_RUN")
	await move_towards_target(approach_speed_cutscene, stop_distance_cutscene)
	await _play_dialogue("first")


func _repeat_meeting():
	await _play_dialogue("repeat")


func _bell_strike():
	if is_disabled:
		return

	bell_area_door.open_door()
	bell_area_door.locked = false
	animated_sprite_2d.play("BELL_SOUND")
	await get_tree().create_timer(1).timeout
	await _play_dialogue("bell")
	animated_sprite_2d.play("BELL_RUN")
	player.is_cutscene_locked = false

	run_and_hide()




func _play_dialogue(cue: String):
	if is_disabled:
		return

	animated_sprite_2d.play("IDLE_ANGRY")
	animated_sprite_2d.stop()

	dialogue_action.first_cue = cue
	dialogue_action.trigger()
	player.is_cutscene_locked = false

	await DialogueManager.dialogue_ended
	await get_tree().create_timer(1.5).timeout



func move_towards_target(speed: float, stop_dist: float, target: Node3D = player, interruptible: bool = false) -> bool:
	while true:
		if interruptible and is_bell_strike:
			velocity = Vector3.ZERO
			return false

		var to_target: Vector3 = target.global_position - global_position
		to_target.y = 0.0

		if to_target.length() <= stop_dist:
			break

		nav_agent.target_position = target.global_position
		var next_pos: Vector3 = nav_agent.get_next_path_position()

		var direction: Vector3 = next_pos - global_position
		direction.y = 0.0
		direction = direction.normalized()

		var delta_time: float = get_physics_process_delta_time()

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if not is_on_floor():
			velocity += get_gravity() * delta_time

		move_and_slide()

		await get_tree().physics_frame

	velocity = Vector3.ZERO
	return true


func catch_player() -> void:
	if is_disabled:
		return

	bell_area_door.locked = false

	player.is_cutscene_locked = true
	animated_sprite_2d.play("idle")

	await FadeInOut.fade_in()

	player.velocity = Vector3.ZERO
	player.global_position = player_outside_pos.global_position
	player.rotation.y = player_outside_pos.global_rotation.y
	velocity = Vector3.ZERO
	global_transform = _start_transform

	_trigger_open_gates()

	await FadeInOut.fade_out()

	player.is_cutscene_locked = false
	_cutscene_started = false


func _trigger_open_gates() -> void:
	if is_disabled:
		return

	for gate: OpenDoorAction in get_tree().get_nodes_in_group("corridor_gates"):
		if gate.is_open:
			gate.trigger()


func run_and_hide():
	await move_towards_target(10, 1, prior_hidden_pos)
	is_disabled = true

	DialogueData.hide_after_dialogue(self)
