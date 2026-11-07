extends Node

@warning_ignore("unused_signal")
signal puzzle_started(lock_player: bool)
@warning_ignore("unused_signal")
signal puzzle_ended(puzzle: Puzzle)

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


func add_puzzle_to_scene(puzzle: Puzzle) -> void:
	get_tree().current_scene.add_child(puzzle)
#func start_puzzle(puzzle: Puzzles):
	#var p: Puzzle = puzzle_scripts[puzzle]
	#p.start()

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
			puzzle_scripts[Puzzles.ASTROLABUS_PUZZLE] = node as Puzzle
