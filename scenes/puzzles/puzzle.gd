@abstract
class_name Puzzle
extends Node

signal puzzle_started
signal puzzle_finished(solved: bool)

@export var lock_player_movement: bool = false


@abstract func start()
@abstract func finish(solved: bool)
