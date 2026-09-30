## a 3D RayCast made to allow the player to interact with [InteractionArea] (only). [br]
##[br]
## NOTE: if you wish to allow a specific interaction from further away or closer up,
## read [InteractionArea] script.
class_name PlayerRayCast
extends RayCast3D


var inter: InteractionArea
var message_sent: bool = false


func _process(_delta: float) -> void:
	var collider: Node3D = get_collider()

	if collider is InteractionArea:
		if inter == collider:
			return

		if inter:
			inter.on_ray_exit()

		inter = collider
		inter.on_ray_enter()

	else:
		if inter:
			inter.on_ray_exit()
			inter = null
