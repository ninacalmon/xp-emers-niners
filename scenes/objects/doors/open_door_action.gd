class_name OpenDoorAction
extends ActionTrigger

@export var flip: bool = false
@export var speed: float = 0.4

@export var collision_shape_3d: CollisionShape3D
@export var mesh_instance_3d: MeshInstance3D

@onready var interaction_area: InteractionArea = $InteractionArea

var is_open: bool = false



func _ready() -> void:
	super()

	if flip:
		self.scale.z *= -1

func trigger():
	if is_open:
		await close_door()
	else:
		await open_door()


func ray_enter():
	pass


func ray_exit():
	pass


func open_door():
	is_open = true

	collision_shape_3d.disabled = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(mesh_instance_3d, "rotation:y", deg_to_rad(95), speed)

	await tween.finished


func close_door():
	is_open = false

	collision_shape_3d.disabled = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(mesh_instance_3d, "rotation:y", deg_to_rad(0), speed)

	await tween.finished

	collision_shape_3d.disabled = false
