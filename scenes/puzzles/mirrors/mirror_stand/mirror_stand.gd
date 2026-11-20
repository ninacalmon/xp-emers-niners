class_name Mirror
extends StaticBody3D

var enabled: bool = true


## local axis the reflective face points to.
@export var reflective_normal_local: Vector3 = Vector3.RIGHT
@export_range(-260.0, 360.0, 0.00000000000001)
var correct_rotation: float = 0.123456789


func _ready():
	print("ESPELHO: ",name, " - ROTATIO: ",global_rotation.y)

func get_reflective_normal() -> Vector3:
	if not enabled:
		return Vector3.ZERO
	return (global_basis.orthonormalized() * reflective_normal_local).normalized()
