class_name ItemFocusView
extends Node3D


@export var item_mesh: Node3D
@export var fov_min: float = 30.0
@export var fov_max: float = 90.0

var fov_step: float = 5.0

var default_rot: Vector3

var is_active: bool = true

@onready var camera_3d: Camera3D = $Camera3D

func _ready() -> void:
	print("camera script ready: ", name, " | processing input: ", is_processing_input())
	default_rot = item_mesh.global_rotation


func revert_rotation():
	item_mesh.global_rotation = default_rot


func zoom(direction: int) -> void:
	var new_fov: float = camera_3d.fov + fov_step * direction
	camera_3d.fov = clampf(new_fov, fov_min, fov_max)
