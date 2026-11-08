extends CharacterBody3D

@export var player_detection: Area3D
@export var player_outside_pos: Marker3D

@export var approach_speed_cutscene: float = 1.0
@export var stop_distance_cutscene: float = 1.3

@export var approach_speed: float = 2
@export var stop_distance: float = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $SubViewportSprite/AnimatedSprite2D
@onready var dialogue_action: DialogueAction = $DialogueAction
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var player: Player
var _cutscene_started: bool = false
var _start_transform: Transform3D


func _ready() -> void:
	_start_transform = global_transform
	player_detection.body_entered.connect(_on_body_entered_player_detec)


func _on_body_entered_player_detec(body: Node3D) -> void:
	if _cutscene_started or not body is Player:
		return

	_cutscene_started = true
	player = body as Player

	start_cutscene()


func start_cutscene() -> void:
	player.is_cutscene_locked = true

	await player.look_at_target(global_position + Vector3(0, 1, 0), 1.0)
	await get_tree().create_timer(1.0).timeout

	animated_sprite_2d.play("BELL_RUN")
	await move_towards_player(approach_speed_cutscene, stop_distance_cutscene)
	animated_sprite_2d.play("idle")

	dialogue_action.trigger()
	player.is_cutscene_locked = false

	await DialogueManager.dialogue_ended
	await get_tree().create_timer(1.5).timeout

	animated_sprite_2d.play("BELL_RUN")
	await move_towards_player(approach_speed, stop_distance)

	await catch_player()


func move_towards_player(speed: float, stop_dist: float) -> void:
	while true:
		var to_player: Vector3 = player.global_position - global_position
		to_player.y = 0.0

		if to_player.length() <= stop_dist:
			break

		nav_agent.target_position = player.global_position
		var map: RID = nav_agent.get_navigation_map()
		print("regions: ", NavigationServer3D.map_get_regions(map).size())
		print("path: ", nav_agent.get_current_navigation_path())
		print("next: ", nav_agent.get_next_path_position(), " | me: ", global_position)
		var next_pos: Vector3 = nav_agent.get_next_path_position()

		var direction: Vector3 = next_pos - global_position
		direction.y = 0.0
		direction = direction.normalized()

		velocity = direction * speed
		move_and_slide()

		await get_tree().physics_frame

	velocity = Vector3.ZERO


func catch_player() -> void:
	player.is_cutscene_locked = true
	animated_sprite_2d.play("idle")

	await FadeInOut.fade_in()

	player.velocity = Vector3.ZERO
	player.global_position = player_outside_pos.global_position
	player.rotation.y = player_outside_pos.global_rotation.y
	velocity = Vector3.ZERO
	global_transform = _start_transform

	await FadeInOut.fade_out()

	player.is_cutscene_locked = false
	_cutscene_started = false
