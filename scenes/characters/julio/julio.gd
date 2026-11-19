extends Node3D

@export var brute_force_first_dialogue: bool = true:
	set(value):
		brute_force_first_dialogue = value
		if dialogue_action and value == true:
			dialogue_action.trigger()
@onready var dialogue_action: DialogueAction = $DialogueAction


func _ready() -> void:
	if brute_force_first_dialogue:
		dialogue_action.trigger()
