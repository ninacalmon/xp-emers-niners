class_name StartPuzzleAction
extends ActionTrigger

var puzzle: Puzzle

func _ready() -> void:
	super()

	puzzle = get_parent().get_parent()


func trigger():
	puzzle.start()

func ray_enter():
	pass


func ray_exit():
	pass
