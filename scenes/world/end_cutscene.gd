extends Area3D

var player: Player
@export var dialogue_res: DialogueResource

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body is Player:
		return

	player = body
	start()
	


func start():
	TimeManager.set_time(TimeManager.Times.at2400)
	DialogueManager.show_dialogue_balloon(dialogue_res, "start")
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(3).timeout
	LoadingManager.load_scene("res://scenes/interface/main_menu/main_menu.tscn")
