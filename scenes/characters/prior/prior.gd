extends CharacterBody3D

const REPATH_INTERVAL: float = 0.25
const STUCK_CHECK_INTERVAL: float = 0.5
const STUCK_MIN_DISTANCE: float = 0.15
const STUCK_MAX_STRIKES: int = 3
const ACCELERATION: float = 20.0
const STEP_HEIGHT: float = 0.35

@export var player_detection: Area3D
@export var player_outside_pos: Marker3D
@export var prior_bell_pos: Marker3D
@export var prior_hidden_pos: Marker3D
@export var bell_area_door: OpenDoorAction
@export var deposit_door: OpenDoorAction

@export var approach_speed_cutscene: float = 1.0
@export var stop_distance_cutscene: float = 1.3

@export var approach_speed: float = 1.2
@export var stop_distance: float = 0.7

@onready var animated_sprite_2d: AnimatedSprite2D = $SubViewportSprite/AnimatedSprite2D
@onready var dialogue_action: DialogueAction = $DialogueAction
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Player
var bell: ChurchBell
var _cutscene_started: bool = false
var _has_met_player: bool = false
var _start_transform: Transform3D
var is_bell_strike: bool = false

var is_chatting: bool = false:
	set(value):
		is_chatting = value
		if value:
			dialogue_action.start_chatting()
		else:
			dialogue_action.stop_chatting()


var is_disabled: bool = false

func _ready() -> void:
	deposit_door.locked = true
	_start_transform = global_transform
	player_detection.body_entered.connect(_on_body_entered_player_detec)

	bell = get_tree().get_first_node_in_group("bell")
	if bell:
		bell.bell_toll.connect(_on_bell_toll)


func _on_bell_toll() -> void:
	if is_disabled:
		return

	_cancel_lockpick() # new
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

	bell_area_door.locked = false
	deposit_door.locked = false
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
	var delta_time: float = get_physics_process_delta_time()
	var nav_map: RID = nav_agent.get_navigation_map()

	var repath_timer: float = 0.0
	var stuck_timer: float = 0.0
	var stuck_strikes: int = 0
	var last_check_pos: Vector3 = global_position

	while true:
		if interruptible and is_bell_strike:
			velocity = Vector3.ZERO
			return false

		if not is_instance_valid(target):
			velocity = Vector3.ZERO
			return false

		var to_target: Vector3 = target.global_position - global_position
		to_target.y = 0.0
		if to_target.length() <= stop_dist:
			break

		# Repath only a few times per second, snapped to the navmesh
		repath_timer -= delta_time
		if repath_timer <= 0.0:
			repath_timer = REPATH_INTERVAL
			nav_agent.target_position = NavigationServer3D.map_get_closest_point(nav_map, target.global_position)

		# Stuck detection
		stuck_timer += delta_time
		if stuck_timer >= STUCK_CHECK_INTERVAL:
			stuck_timer = 0.0
			var moved: float = (global_position - last_check_pos).length()
			last_check_pos = global_position
			if moved < STUCK_MIN_DISTANCE:
				stuck_strikes += 1
				repath_timer = 0.0 # force a fresh path
				if stuck_strikes >= STUCK_MAX_STRIKES:
					velocity = Vector3.ZERO
					return false
			else:
				stuck_strikes = 0

		var next_pos: Vector3 = nav_agent.get_next_path_position()
		var direction: Vector3 = next_pos - global_position
		direction.y = 0.0
		direction = direction.normalized()

		# Smooth acceleration instead of instant velocity
		var desired: Vector3 = direction * speed
		velocity.x = move_toward(velocity.x, desired.x, ACCELERATION * delta_time)
		velocity.z = move_toward(velocity.z, desired.z, ACCELERATION * delta_time)

		if not is_on_floor():
			velocity += get_gravity() * delta_time

		if is_on_floor():
			_try_step_up(direction)

		move_and_slide()
		await get_tree().physics_frame

	velocity = Vector3.ZERO
	return true


func catch_player() -> void:
	if is_disabled:
		return

	_cancel_lockpick() # new
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


func _cancel_lockpick() -> void:
	var qte: LockpickQTE = get_tree().get_first_node_in_group("lockpick_qte") as LockpickQTE
	if qte:
		qte.cancel()




func _try_step_up(direction: Vector3) -> void:
	if direction.length_squared() < 0.0001:
		return
	var probe: Vector3 = direction.normalized() * 0.15
	var raised: Transform3D = global_transform.translated(Vector3.UP * STEP_HEIGHT)
	# Blocked at foot level but free one step higher: hop up
	if test_move(global_transform, probe) and not test_move(raised, probe):
		global_position.y += STEP_HEIGHT
