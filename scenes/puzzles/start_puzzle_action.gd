class_name StartPuzzleAction
extends ActionTrigger

var puzzle: Puzzle
@export var mesh_instance_3d: MeshInstance3D

func _ready() -> void:
	super()

	puzzle = get_parent().get_parent()


func trigger():
	puzzle.start()
	mesh_instance_3d.set_instance_shader_parameter("outline_enabled", false)

func ray_enter():
	pass


func ray_exit():
	pass
