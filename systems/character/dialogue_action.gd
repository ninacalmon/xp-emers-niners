class_name DialogueAction
extends ActionTrigger

signal dialogue_started
signal dialogue_ended

signal next_dialogue

signal ray_entered
signal ray_exited

signal speech_line_finished

@export var character_name: String = ""
@export var dialogue_res: DialogueResource
@export var first_cue: String = "start"

var is_showing_dialogue: bool = false

@onready var balloon: DialogueManagerExampleBalloon 



func trigger():
	if is_showing_dialogue:
		return

	balloon = DialogueManager.show_dialogue_balloon(dialogue_res, first_cue)
	balloon.line_finished.connect(_on_line_finished)


func ray_enter():
	ray_entered.emit()


func ray_exit():
	ray_exited.emit()


func _ready() -> void:
	super()

	force_outline_off = true

	DialogueManager.got_dialogue.connect(_on_dialog_got)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialog_ended)



func _on_dialog_got(line: DialogueLine):
	if line.character != str(character_name):
		return
	next_dialogue.emit()


func _on_dialogue_started(resource: DialogueResource):
	is_showing_dialogue = true
	if resource == dialogue_res:
		dialogue_started.emit()


func _on_dialog_ended(resource: DialogueResource):
	is_showing_dialogue = false
	if resource == dialogue_res:
		dialogue_ended.emit()


func _on_line_finished(_line: DialogueLine):
	speech_line_finished.emit()
