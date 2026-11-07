@abstract
class_name Puzzle
extends Node

@warning_ignore("unused_signal")
signal puzzle_started
@warning_ignore("unused_signal")
signal puzzle_finished(solved: bool)

@export var lock_player_movement: bool = false


@abstract func start()
@abstract func finish(solved: bool)
