class_name Mirror
extends StaticBody3D

## local axis the reflective face points to.
@export var reflective_normal_local: Vector3 = Vector3.RIGHT


func get_reflective_normal() -> Vector3:
	return (global_basis.orthonormalized() * reflective_normal_local).normalized()
