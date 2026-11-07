extends Control

@export var rays_rotation_speed: float = 0.025
@export var iris_max_offset: Vector2 = Vector2(50.0, 18.0)
@export var iris_follow_speed: float = 2.0
@export var idle_animation: StringName = &"idle" 

@onready var sun_rays_pivot: Node2D = $SunRaysPivot
@onready var sun_iris_pivot: Node2D = $SunIrisPivot
@onready var sun_face: AnimatedSprite2D = $SunFace
@onready var eyes_area: Area2D = $EyesArea

var iris_origin: Vector2 = Vector2.ZERO
var is_hovering_eyes: bool = false
#var is_closing_game: bool = false


func _ready() -> void:
	iris_origin = sun_iris_pivot.position
	sun_face.play(idle_animation)
	eyes_area.mouse_entered.connect(_on_eyes_mouse_entered)
	eyes_area.mouse_exited.connect(_on_eyes_mouse_exited)
	eyes_area.input_event.connect(_on_eyes_input_event)


func _process(delta: float) -> void:
	rotate_rays(delta)
	follow_mouse_iris(delta)


func rotate_rays(delta: float) -> void:
	sun_rays_pivot.rotation += rays_rotation_speed * delta


func follow_mouse_iris(delta: float) -> void:
	if not sun_iris_pivot.visible:
		return

	var mouse_pos: Vector2 = get_local_mouse_position()
	var offset: Vector2 = mouse_pos - iris_origin

	var normalized_offset := Vector2(
		offset.x / iris_max_offset.x,
		offset.y / iris_max_offset.y
	)

	normalized_offset = normalized_offset.limit_length(1.0)

	var target := iris_origin + Vector2(
		normalized_offset.x * iris_max_offset.x,
		normalized_offset.y * iris_max_offset.y
	)

	var weight := 1.0 - exp(-iris_follow_speed * delta)
	sun_iris_pivot.position = sun_iris_pivot.position.lerp(target, weight)


func close_eyes_mouse() -> void:
	#if is_closing_game:
		#return
	#is_closing_game = true
	sun_face.play(&"close_eyes")
	#await get_tree().create_timer(1).timeout
	#get_tree().quit()


func _on_eyes_mouse_entered() -> void:
	#if is_closing_game:
		#return
	is_hovering_eyes = true
	sun_face.play(&"closing_eyes")


func _on_eyes_mouse_exited() -> void:
	#if is_closing_game:
		#return
	is_hovering_eyes = false
	sun_face.play("opening")


func _on_eyes_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event != null and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		close_eyes_mouse()
