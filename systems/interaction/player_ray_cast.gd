## a 3D RayCast made to allow the player to interact with [InteractionArea] (only). [br]
##[br]
## NOTE: if you wish to allow a specific interaction from further away or closer up,
## read [InteractionArea] script.
class_name PlayerRayCast
extends RayCast3D

@onready var interaction_overlay: InteractionOverlay = $InteractionOverlay

var inter: InteractionArea
var deactive_callers: Array[String]
var _is_deactivated: bool = false

func _process(_delta: float) -> void:
	if _is_deactivated:
		return

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



func deactivate(variation: String, is_deactivated: bool) -> void:
	if is_deactivated:
		if not deactive_callers.has(variation):
			deactive_callers.append(variation)
	else:
		deactive_callers.erase(variation)

	var is_free: bool = deactive_callers.is_empty()
	enabled = is_free
	interaction_overlay.visible = is_free
	_is_deactivated = not is_free

	if inter:
		if not is_free:
			inter.on_ray_exit()
			inter = null
	print("deactive_callers: ", deactive_callers)
