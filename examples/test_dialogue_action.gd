extends ActionTrigger


func trigger():
	DialogueManager.show_dialogue_balloon(load("res://dialogue/tests/tests_ball.dialogue"), "start")
	

func ray_enter():
	pass


func ray_exit():
	pass
