class_name InteractableArea
extends Area3D

@export var close_area: CloseArea
@export var mesh: MeshInstance3D

var checking_input: bool = false

func _ready() -> void:
	# later, add a check if the mesh has the proper shader or not.

	close_area.player_near.connect(_on_player_near)
	close_area.player_far.connect(_on_player_far)

	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)



func _on_hover():
	print("hover")
	mesh.set_instance_shader_parameter("outline_enabled", true)


func _on_unhover():
	mesh.set_instance_shader_parameter("outline_enabled", false)


func _on_player_near():
	input_ray_pickable = true
	checking_input = true


func _on_player_far():
	input_ray_pickable = false
	checking_input = false


func _input(event: InputEvent) -> void:
	if not checking_input:
		return
