extends ActionTrigger

@export var mesh: MeshInstance3D

var material: StandardMaterial3D

func trigger():
	change_color()


func ray_enter():
	pass


func ray_exit():
	pass


func _ready() -> void:
	material = mesh.get_surface_override_material(0)


func change_color():
	material.albedo_color.h = randf_range(0, 1)
	mesh.set_surface_override_material(0, material)
