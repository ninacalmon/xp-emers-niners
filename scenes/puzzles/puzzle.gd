@abstract
class_name Puzzle
extends Node

signal puzzle_started
signal puzzle_finished(solved: bool)

@abstract func start()
@abstract func finish(solved: bool)
