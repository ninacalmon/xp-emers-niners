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
@export var is_chatting: bool = false

var is_showing_dialogue: bool = false
var _chat_loop_running: bool = false
var _resume_chatting: bool = false

var _chatting_mood_bag: Array = []
var _chatting_last_mood: Variant = null

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

	if is_chatting:
		start_chatting()


func _on_dialog_got(line: DialogueLine):
	if line.character != str(character_name):
		return
	next_dialogue.emit()


func _on_dialogue_started(resource: DialogueResource):
	pause_chatting()
	is_showing_dialogue = true
	if resource == dialogue_res:
		dialogue_started.emit()


func _on_dialog_ended(resource: DialogueResource):
	resume_chatting()
	is_showing_dialogue = false
	if resource == dialogue_res:
		dialogue_ended.emit()
	action_ended.emit()


func _on_line_finished(_line: DialogueLine):
	speech_line_finished.emit()


func start_chatting() -> void:
	is_chatting = true
	_resume_chatting = false
	chatting_mode()


func stop_chatting() -> void:
	is_chatting = false
	_resume_chatting = false


func pause_chatting() -> void:
	if not is_chatting:
		return
	_resume_chatting = true
	is_chatting = false


func resume_chatting() -> void:
	if not _resume_chatting:
		return
	_resume_chatting = false
	is_chatting = true
	chatting_mode()



func _pick_mood(moods: Dictionary) -> Variant:
	if _chatting_mood_bag.is_empty():
		_chatting_mood_bag = moods.values()
		_chatting_mood_bag.shuffle()

		if _chatting_mood_bag.size() > 1 and _chatting_mood_bag[0] == _chatting_last_mood:
			var swap_index: int = randi_range(1, _chatting_mood_bag.size() - 1)
			var temp: Variant = _chatting_mood_bag[0]
			_chatting_mood_bag[0] = _chatting_mood_bag[swap_index]
			_chatting_mood_bag[swap_index] = temp

	_chatting_last_mood = _chatting_mood_bag.pop_front()
	return _chatting_last_mood


func _next_delay() -> float:
	if randf() < 0.2:
		return randf_range(2.0, 4.0)
	return randf_range(0.6, 1.8)


func chatting_mode() -> void:
	if _chat_loop_running:
		return
	_chat_loop_running = true

	while is_chatting:
		var moods: Dictionary = DialogueData.MOODS_BY_CHARACTER.get(character_name, {})
		if not moods.is_empty():
			DialogueData.set_mood(character_name, _pick_mood(moods))

		await get_tree().create_timer(_next_delay()).timeout

		if not is_inside_tree():
			break

	_chat_loop_running = false
