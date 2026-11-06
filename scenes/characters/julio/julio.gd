extends Node3D

@export var brute_force_first_dialogue: bool = true
@onready var dialogue_action: DialogueAction = $DialogueAction


func _ready() -> void:
	if brute_force_first_dialogue:
		dialogue_action.trigger()
