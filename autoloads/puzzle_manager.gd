extends Node

@warning_ignore("unused_signal")
signal puzzle_started(lock_player: bool)
@warning_ignore("unused_signal")
signal puzzle_ended(puzzle: Puzzle)

enum Puzzles {
	ASTROLABUS_PUZZLE,
	TUMOUR_PUZZLE,
	}

var puzzle_scripts: Dictionary[Puzzles, Puzzle] = {
	Puzzles.ASTROLABUS_PUZZLE : null,
	Puzzles.TUMOUR_PUZZLE : null,
}

func _ready() -> void:
	await get_tree().process_frame
	_find_puzzles()


func get_puzzle(puzzle: Puzzles) -> Puzzle:
	var p: Puzzle = puzzle_scripts.get(puzzle, null)

	if not is_instance_valid(p):
		_find_puzzles()
		p = puzzle_scripts.get(puzzle, null)

	if not is_instance_valid(p):
		push_warning("Puzzle not found in the current scene: %s" % Puzzles.keys()[puzzle])
		return null

	return p


func _find_puzzles() -> void:
	var puzzles: Array[Node] = get_tree().get_nodes_in_group("puzzles")
	for node: Node in puzzles:
		if node is AstrolabusPuzzle:
			puzzle_scripts[Puzzles.ASTROLABUS_PUZZLE] = node as AstrolabusPuzzle
		elif node is TumourPuzzle:
			puzzle_scripts[Puzzles.TUMOUR_PUZZLE] = node as TumourPuzzle
