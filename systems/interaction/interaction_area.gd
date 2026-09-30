## this node goes with any object from which player can interact with via [PlayerRayCast].[br]
##[br]
##NOTE: the needed [CollisionShape3D] should be, per usual, about the size of the object's [MeshInstance3D].
## if you wish to allow a specific interaction from further away or closer up, change
## the [CollisionShape3D] size.
class_name InteractionArea
extends Area3D

var checking_input: bool = false

@export var mesh: MeshInstance3D
@export var action_trigger: ActionTrigger


## called by [PlayerRayCast]. means player is close enough and looking directly at.
func on_ray_enter():
	checking_input = true
	action_trigger.ray_enter()
	mesh.set_instance_shader_parameter("outline_enabled", true)


## called by [PlayerRayCast]. means player is not close enough anymore or looked away.
func on_ray_exit():
	checking_input = false
	action_trigger.ray_exit()
	mesh.set_instance_shader_parameter("outline_enabled", false)


func _input(event: InputEvent) -> void:
	if not checking_input:
		return

	## "interact" input action is currently triggered by lmb or 'E' for tests and will be changed.
	if event.is_action_pressed("interact"):
		print("clicked")
		action_trigger.trigger()


func _ready() -> void:
	## Guarantees that mesh have outline_shader_material.tres as material overlay. vvv
	assert(
	(
		mesh.material_overlay and
		mesh.material_overlay.resource_path.ends_with("outline_shader_material.tres")
	),
	"mesh does not have outline_shader_material.tres as material overlay!"
	)

	## WARNING: do not change! vvv
	monitoring = false
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
