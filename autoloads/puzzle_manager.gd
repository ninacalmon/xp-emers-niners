extends Node

signal puzzle_started(lock_player: bool)
signal puzzle_ended()

enum Puzzles {
	ASTROLABUS_PUZZLE,
	}

var puzzle_scripts: Dictionary[Puzzles, Puzzle] = {
	Puzzles.ASTROLABUS_PUZZLE : null,
}

func _ready() -> void:
	await get_tree().process_frame
	var puzzles = get_tree().get_nodes_in_group("puzzles")
	for p in puzzles:
		if p is AstrolabusPuzzle:
			puzzle_scripts[Puzzles.ASTROLABUS_PUZZLE] = p
			print("astrolab got")


#func start_puzzle(puzzle: Puzzles):
	#var p: Puzzle = puzzle_scripts[puzzle]
	#p.start()
