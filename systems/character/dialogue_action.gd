class_name DialogAction
extends ActionTrigger

signal mood_changed(new_mood: String)

signal dialogue_started
signal dialogue_ended

signal ray_entered
signal ray_exited

@export var dialogue_res: DialogueResource
@export var first_cue: String = "start"

var cue_mood: String:
	set(value):
		if cue_mood != value:
			mood_changed.emit(value)
			cue_mood = value

func trigger():
	DialogueManager.show_dialogue_balloon(dialogue_res, first_cue)


func ray_enter():
	ray_entered.emit()


func ray_exit():
	ray_exited.emit()


func _ready() -> void:
	super()

	DialogueManager.got_dialogue.connect(_on_dialog_got)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialog_ended)


func _on_dialog_got(line: DialogueLine):
	var _mood = line.get_tag_value("mood")
	if _mood and _mood != "":
		cue_mood = _mood


func _on_dialogue_started(resource: DialogueResource):
	if resource == dialogue_res:
		dialogue_started.emit()


func _on_dialog_ended(resource: DialogueResource):
	if resource == dialogue_res:
		dialogue_ended.emit()
