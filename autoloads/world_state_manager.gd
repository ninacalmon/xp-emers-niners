extends Node


func play_starting_cutscene():
	var starting_cutscene: StartingCutscene = get_tree().current_scene.get_node_or_null(
		"Cutscenes/StartingCutscene") as StartingCutscene
	if starting_cutscene == null:
		push_error("StartingCutscene not found in the current scene")

	starting_cutscene.play_cutscene()
