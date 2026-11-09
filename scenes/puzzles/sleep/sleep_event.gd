extends Puzzle
class_name SleepPuzzle

const ANIM_ASLEEP: StringName = &"ASLEEP"
const ANIM_AWAKE: StringName = &"AWAKE"

@export var sanson_asleep_dialogue_res: DialogueResource
@export var item_in_world: ItemInWorld
@export var player_detection: Area3D
@export var animated_sprite_2d: AnimatedSprite2D
@export var sanson: DialogueAction
@export var door_blocker: CollisionShape3D
@export var sanson_interact_collision_shape_3d: CollisionShape3D

var _started: bool = false
var _sanson_awake: bool = false
var _player_inside: bool = false

#func _physics_process(_delta: float) -> void:
	#if not _started or Engine.get_physics_frames() % 60 != 0:
		#return
	#print("[SleepPuzzle] monitoring: ", player_detection.monitoring, " | overlapping: ", player_detection.get_overlapping_bodies())


func _ready() -> void:
	item_in_world.deactivate = true
	player_detection.monitoring = false
	door_blocker.disabled = true
	player_detection.body_entered.connect(_on_player_detection_body_entered)
	player_detection.body_exited.connect(_on_player_detection_body_exited)
	item_in_world.picked_up.connect(_on_item_picked_up)
	DialogueData.start_sanson_sleep.connect(start)


func start() -> void:
	if _started:
		return
	_started = true
	print("[SleepPuzzle] start()")
	
	#player_detection.collision_mask = 0xFFFFFFFF
	
	sanson_interact_collision_shape_3d.disabled = true
	sanson.dialogue_res = sanson_asleep_dialogue_res
	item_in_world.deactivate = false
	animated_sprite_2d.play(ANIM_ASLEEP)

	player_detection.monitoring = true


func finish(solved: bool) -> void:
	player_detection.set_deferred("monitoring", false)
	door_blocker.set_deferred("disabled", true)
	puzzle_finished.emit(solved)


func _on_item_picked_up() -> void:
	if not _started:
		return
	TimeManager.set_time(TimeManager.Times.at2100)
	finish(true)


func _on_player_detection_body_entered(body: Node3D) -> void:
	print("[SleepPuzzle] body_entered: ", body.name, " groups: ", body.get_groups())
	if not body is Player:
		return

	_player_inside = true

	var is_drunk: bool = body._is_drunk
	print("[SleepPuzzle] is_drunk: ", is_drunk)
	if is_drunk or _sanson_awake:
		return

	_wake_sanson_and_block()


func _on_player_detection_body_exited(body: Node3D) -> void:
	if not body is Player:
		return

	_player_inside = false
	_sleep_sanson()


func _wake_sanson_and_block() -> void:
	_sanson_awake = true
	animated_sprite_2d.play(ANIM_AWAKE)

	# Player left while Sanson was waking up: _sleep_sanson() already handled it.
	if not _sanson_awake or not _player_inside:
		return

	sanson.trigger()
	await DialogueManager.dialogue_ended

	if _sanson_awake:
		door_blocker.set_deferred("disabled", false)


func _sleep_sanson() -> void:
	_sanson_awake = false
	door_blocker.set_deferred("disabled", true)
	animated_sprite_2d.play(ANIM_ASLEEP)
