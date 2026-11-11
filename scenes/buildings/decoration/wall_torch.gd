@tool
extends Node3D
class_name WallTorch

@export_tool_button("Flip X") var flip_x_button: Callable = _flip.bind(Vector3.AXIS_X)
@export_tool_button("Flip Y") var flip_y_button: Callable = _flip.bind(Vector3.AXIS_Y)
@export_tool_button("Flip Z") var flip_z_button: Callable = _flip.bind(Vector3.AXIS_Z)


func _flip(axis: Vector3.Axis) -> void:
	var local_axis: Vector3
	match axis:
		Vector3.AXIS_X:
			local_axis = Vector3.RIGHT
		Vector3.AXIS_Y:
			local_axis = Vector3.UP
		_:
			local_axis = Vector3.BACK

	rotate_object_local(local_axis, PI)
