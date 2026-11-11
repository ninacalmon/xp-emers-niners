class_name OpenDoorAction
extends ActionTrigger

@export var open_rotation: int = 95
@export var flip: bool = false
@export var speed: float = 0.4

@export var collision_shape_3d: CollisionShape3D
@export var mesh_instance_3d: Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

@export var locked: bool = false
@export var locked_stream_player: AudioStreamPlayer

var is_open: bool = false



func _ready() -> void:
	super()

	if flip:
		self.scale.z *= -1


func trigger():
	if locked and wanted_item:
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


func open_door():
	is_open = true

	collision_shape_3d.disabled = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(mesh_instance_3d, "rotation:y", deg_to_rad(open_rotation), speed)

	await tween.finished


func close_door():
	is_open = false

	collision_shape_3d.disabled = true

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(mesh_instance_3d, "rotation:y", deg_to_rad(0), speed)

	await tween.finished

	collision_shape_3d.disabled = false


func shake_door():
	var original_rotation = mesh_instance_3d.rotation.y
	var shake_amount = deg_to_rad(3.0)
	var shake_duration = 0.06

	var tween = create_tween()
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation + shake_amount, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation - shake_amount, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation + shake_amount * 0.5, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation, shake_duration)

	await tween.finished
