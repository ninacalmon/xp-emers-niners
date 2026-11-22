extends Node3D

@onready var sprite_3d: Sprite3D = $Sprite3D

var is_chatting: bool = false:
	set(value):
		is_chatting = value
		if value:
			dialogue_action.start_chatting()
		else:
			dialogue_action.stop_chatting()

@export var brute_force_first_dialogue: bool = true:
	set(value):
		brute_force_first_dialogue = value
		if dialogue_action and value == true:
			dialogue_action.trigger()

@onready var dialogue_action: DialogueAction = $DialogueAction


func _ready() -> void:
	if brute_force_first_dialogue:
		dialogue_action.trigger()
