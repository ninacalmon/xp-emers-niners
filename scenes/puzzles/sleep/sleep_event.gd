extends Puzzle
class_name SleepPuzzle


const ANIM_ASLEEP: StringName = &"ASLEEP"
const ANIM_AWAKE: StringName = &"AWAKE"

@export var sanson_asleep_dialogue_res: DialogueResource
@export var lock_pick: ItemInWorld
@export var lock_pick_pos: Marker3D

@export var player_detection: Area3D
@export var animated_sprite_2d: AnimatedSprite2D
@export var sanson: DialogueAction
@export var door_blocker: CollisionShape3D
@export var sanson_interact_collision_shape_3d: CollisionShape3D
@onready var sanson_sleep_pos: Marker3D = $sanson_sleep_pos

var _started: bool = false
var flower_got: bool = false
var _sanson_awake: bool = false
var _player_inside: bool = false
var _ignore_visit: bool = false # true if the player entered drunk

#func _physics_process(_delta: float) -> void:
	#if not _started or Engine.get_physics_frames() % 60 != 0:
		#return
	#print("[SleepPuzzle] monitoring: ", player_detection.monitoring, " | overlapping: ", player_detection.get_overlapping_bodies())


func _ready() -> void:
	#Engine.time_scale = 3
	lock_pick.deactivate = true
	player_detection.monitoring = false
	door_blocker.disabled = true
	player_detection.body_entered.connect(_on_player_detection_body_entered)
	player_detection.body_exited.connect(_on_player_detection_body_exited)
	lock_pick.picked_up.connect(_on_item_picked_up)
	DialogueData.start_sanson_sleep.connect(start)


func start() -> void:
	if _started:
		return

	_started = true
	flower_got = CharacterData.Sanson.flower_got

	sanson.global_position = sanson_sleep_pos.global_position
	
	#player_detection.collision_mask = 0xFFFFFFFF

	sanson_interact_collision_shape_3d.disabled = true
	sanson.dialogue_res = sanson_asleep_dialogue_res
	sanson.stop_chatting()
	animated_sprite_2d.play(ANIM_ASLEEP)

	# Without the flower the astrolabe stays where it is and stays deactivated.
	# Sanson still wakes up, talks to the player and blocks the door.
	if flower_got:
		lock_pick.global_transform = lock_pick_pos.global_transform
		lock_pick.deactivate = false

	player_detection.monitoring = true


func finish(solved: bool) -> void:
	#player_detection.set_deferred("monitoring", false)
	#door_blocker.set_deferred("disabled", true)
	puzzle_finished.emit(solved)


func _on_item_picked_up() -> void:
	if not _started or not flower_got:
		return
	TimeManager.set_time(TimeManager.Times.at2100)
	TaskManager.complete_task("get_keys")
	finish(true)


func _on_player_detection_body_entered(body: Node3D) -> void:
	print("[SleepPuzzle] body_entered: ", body.name, " groups: ", body.get_groups())
	if not body is Player:
		return

	_player_inside = true

	var is_drunk: bool = body._is_drunk
	print("[SleepPuzzle] is_drunk: ", is_drunk)

	# Decision is locked at entry: if the player entered drunk, ignore this
	# visit completely, even if they become sober while still inside.
	_ignore_visit = is_drunk
	if _ignore_visit or _sanson_awake:
		return

	_wake_sanson_and_block()


func _on_player_detection_body_exited(body: Node3D) -> void:
	if not body is Player:
		return

	_player_inside = false
	_ignore_visit = false # next entry is evaluated from scratch
	_sleep_sanson()


func _wake_sanson_and_block() -> void:
	_sanson_awake = true
	animated_sprite_2d.play(ANIM_AWAKE)

	sanson.trigger()
	await DialogueManager.dialogue_ended

	# Player may have left during the dialogue: _sleep_sanson() already handled it.
	if _sanson_awake and _player_inside:
		door_blocker.set_deferred("disabled", false)


func _sleep_sanson() -> void:
	_sanson_awake = false
	door_blocker.set_deferred("disabled", true)
	animated_sprite_2d.play(ANIM_ASLEEP)
