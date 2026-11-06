extends Node3D

@onready var confessor: Node3D = $Confessor
@onready var dialogue_action: DialogueAction = $DialogueAction
const CONFESSOR_MAIN = preload("uid://cdxegtuh7g6l4")
const CONFESSOR_AUSENT = preload("uid://dbjgecmd6hewe")


@export var confissor_is_there: bool = false:
	set(value):
		confissor_is_there = value
		set_confissor(value)


func set_confissor(is_there: bool):
	if is_there:
		confessor.show()
		dialogue_action.dialogue_res = CONFESSOR_MAIN
	else:
		confessor.hide()
		dialogue_action.dialogue_res = CONFESSOR_AUSENT


func _ready() -> void:
	set_confissor(confissor_is_there)
