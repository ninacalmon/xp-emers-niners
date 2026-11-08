class_name DoubleDoorAction
extends ActionTrigger

@export var open_rotation: int = 95
@export var flip: bool = false
@export var speed: float = 0.4

@export var collision_shapes: Array[CollisionShape3D] = []

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var r_door_pivot: Node3D = $RDoorPivot
@onready var l_door_pivot: Node3D = $LDoorPivot

@export var locked: bool = false
@export var locked_stream_player: AudioStreamPlayer

var is_open: bool = false
var _r_closed_y: float = 0.0
var _l_closed_y: float = 0.0


func _ready() -> void:
	super()

	_r_closed_y = r_door_pivot.rotation.y
	_l_closed_y = l_door_pivot.rotation.y


func trigger():
	if locked:
		if InventoryManager.selected_item == wanted_item:
			locked = false
			locked_stream_player.play()
		else:
			locked_stream_player.play()
			await shake_door()
			return

	if is_open:
		await close_door()
	else:
		await open_door()


func ray_enter():
	pass


func ray_exit():
	pass


func open_door() -> void:
	is_open = true

	_set_collisions_disabled(true)

	var angle: float = deg_to_rad(float(open_rotation))
	if flip:
		angle = -angle

	await _rotate_doors(_r_closed_y - angle, _l_closed_y + angle)


func close_door() -> void:
	is_open = false

	_set_collisions_disabled(true)

	await _rotate_doors(_r_closed_y, _l_closed_y)

	_set_collisions_disabled(false)


func shake_door() -> void:
	var shake_amount: float = deg_to_rad(3.0)
	var shake_duration: float = 0.06

	var r_original: float = r_door_pivot.rotation.y
	var l_original: float = l_door_pivot.rotation.y

	var tween: Tween = create_tween()

	tween.tween_property(r_door_pivot, "rotation:y", r_original + shake_amount, shake_duration)
	tween.parallel().tween_property(l_door_pivot, "rotation:y", l_original - shake_amount, shake_duration)

	tween.tween_property(r_door_pivot, "rotation:y", r_original - shake_amount, shake_duration)
	tween.parallel().tween_property(l_door_pivot, "rotation:y", l_original + shake_amount, shake_duration)

	tween.tween_property(r_door_pivot, "rotation:y", r_original + shake_amount * 0.5, shake_duration)
	tween.parallel().tween_property(l_door_pivot, "rotation:y", l_original - shake_amount * 0.5, shake_duration)

	tween.tween_property(r_door_pivot, "rotation:y", r_original, shake_duration)
	tween.parallel().tween_property(l_door_pivot, "rotation:y", l_original, shake_duration)

	await tween.finished


func _rotate_doors(r_target: float, l_target: float) -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_parallel(true)

	tween.tween_property(r_door_pivot, "rotation:y", r_target, speed)
	tween.tween_property(l_door_pivot, "rotation:y", l_target, speed)

	await tween.finished


func _set_collisions_disabled(value: bool) -> void:
	for shape: CollisionShape3D in collision_shapes:
		shape.disabled = value
