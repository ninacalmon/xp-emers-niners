extends Node

var starting_cutscene_played: bool = false
var barn_cutscene_played: bool = false

func play_starting_cutscene():
	var starting_cutscene: StartingCutscene = get_tree().current_scene.get_node_or_null(
		"Cutscenes/StartingCutscene") as StartingCutscene
	if starting_cutscene == null:
		push_error("StartingCutscene not found in the current scene")

	starting_cutscene.play_cutscene()


func play_animals_ink_cutscene():
	var animals_cutscene: AnimalsCutscene = get_tree().current_scene.get_node_or_null(
		"Cutscenes/AnimalsCutscene") as AnimalsCutscene

	if animals_cutscene == null:
		push_error("AnimalsCutscene notfound in the current scene")

	animals_cutscene.variant = animals_cutscene.Variant.INK
	animals_cutscene.play_cutscene()


func play_animals_plant_cutscene():
	var animals_cutscene: AnimalsCutscene = get_tree().current_scene.get_node_or_null(
		"Cutscenes/AnimalsCutscene") as AnimalsCutscene

	if animals_cutscene == null:
		push_error("AnimalsCutscene notfound in the current scene")

	animals_cutscene.variant = animals_cutscene.Variant.PLANT
	animals_cutscene.play_cutscene()



@export var abbott: Abbott


func fade_abbot(f: bool, time: float = 1):
	abbott = GetEntity.get_abbott()
	var tween = create_tween()
	if f:
		tween.tween_property(abbott.sprite_3d, "modulate", Color.WHITE, time)
	else:
		tween.tween_property(abbott.sprite_3d, "modulate", Color.BLACK, time)
