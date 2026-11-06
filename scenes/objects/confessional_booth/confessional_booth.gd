extends Node3D

@onready var confessor: Node3D = $Confessor
@onready var confessor_collision_shape_3d: CollisionShape3D = $Confessor/StaticBody3D/CollisionShape3D
@onready var interaction_collision_shape_3d: CollisionShape3D = $InteractionArea/CollisionShape3D

@onready var dialogue_action: DialogueAction = $DialogueAction
const CONFESSOR_MAIN = preload("uid://cdxegtuh7g6l4")
const CONFESSOR_AUSENT = preload("uid://dbjgecmd6hewe")


@export var confissor_is_there: bool = false:
	set(value):
		confissor_is_there = value
		set_confissor(value)


func set_confissor(is_there: bool):
	if not is_instance_valid(confessor):
		return
	if is_there:
		confessor.show()
		interaction_collision_shape_3d.disabled = false
		confessor_collision_shape_3d.disabled = false
		dialogue_action.dialogue_res = CONFESSOR_MAIN
	else:
		confessor.hide()
		interaction_collision_shape_3d.disabled = true
		confessor_collision_shape_3d.disabled = true
		dialogue_action.dialogue_res = CONFESSOR_AUSENT


func _ready() -> void:
	set_confissor(confissor_is_there)
