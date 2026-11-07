extends Node

@warning_ignore("unused_signal")
signal medication_quest_completed
@warning_ignore("unused_signal")
signal inkwell_quest_completed


signal mood_set(character_name: String, mood_name: String)


const MOODS_BY_CHARACTER: Dictionary = {
	"Julio": JulioMoods,
	"Lucio": LucioMoods,
	"Hugo": HugoMoods,
	"Sanson" : SansonMoods,
	"Confessor" : ConfessorMoods,
	"Prior" : PriorMoods
}

enum JulioMoods {
	IDLE_ANGRY,
	IDLE_DEFAULT,
	IDLE_HAPPY,
	IDLE_SAD,
	IDLE_SERIOUS,
	IDLE_SURPRISED,
	INTENSE_ANGRY,
	INTENSE_DEFAULT,
	INTENSE_HAPPY,
	INTENSE_SAD,
	INTENSE_SURPRISED,
	SILLY_ANGRY,
	SILLY_DEFAULT,
	SILLY_HAPPY,
	SILLY_SAD,
	SILLY_SURPRISED,
}

enum LucioMoods {
	HAND_ANGRY,
	HAND_DEFAULT,
	HAND_HAPPY,
	HAND_SAD,
	HAND_SURPRISED,
	HEART_ANGRY,
	HEART_DEFAULT,
	HEART_HAPPY,
	HEART_SAD,
	HEART_SURPRISED,
	IDLE_ANGRY,
	IDLE_DEFAULT,
	IDLE_HAPPY,
	IDLE_SAD,
	IDLE_SINIXTRO,
	IDLE_SURPRISED,
}


enum HugoMoods {
	IDLE_ANGRY,
	IDLE_DEFAULT,
	IDLE_HAPPY,
	IDLE_SAD,
	IDLE_SUPERHAPPY,
	IDLE_SURPRISED,
	IDLE_WINK,
	MISCHIVEOUS_DEFAULT,
	MISCHIVEOUS_HAPPY,
	MISCHIVEOUS_SUPERHAPPY,
	MISCHIVEOUS_SURPRISED,
	MISCHIVEOUS_WINK,
	OPENARMS_ANGRY,
	OPENARMS_DEFAULT,
	OPENARMS_HAPPY,
	OPENARMS_SUPERHAPPY,
	OPENARMS_SURPRISED,
	OPENARMS_WINK,
	TUMOR
}


enum SansonMoods {
	CRAZY_DEFAULT,
	CRAZY_HAPPY,
	HAND_ANGRY,
	HAND_DEFAULT,
	HAND_HAPPY,
	HAND_SAD,
	IDLE_ANGRY,
	IDLE_DEFAULT,
	IDLE_HAPPY,
	IDLE_SAD,
	POSING_ANGRY,
	POSING_HAPPY,
	POSING_HAPPYSAD,
	POSING_POUT,
	POSING_SAD,
	AWAKE,
	ASLEEP,
}


enum ConfessorMoods {
	VARIATION,
	idle
}


enum PriorMoods {
	BELL_RUN,
	BELL_SOUND,
	BELL_YELL,
	IDLE_ANGRY,
	IDLE_DEFAULT,
	IDLE_HAPPY,
	IDLE_SAD,
}


func set_mood(character_name: String, mood: int, mouth_shut: bool = false) -> void:
	var moods: Dictionary = MOODS_BY_CHARACTER.get(character_name, {})
	var mood_name: Variant = moods.find_key(mood)
	if mood_name == null:
		push_warning("%s has no mood with value %d" % [character_name, mood])
		return
	mood_set.emit(character_name, str(mood_name), mouth_shut)


func player_in_booth(_player: Player):
	_player.global_position = Vector3(21.437, 1.539, -3.2)
	_player.global_rotation = Vector3(0, -180, 0)
	_player.rotation = Vector3.ZERO
	_player.head.rotation.x = deg_to_rad(-2)
	_player.head.rotation.y = deg_to_rad(180)

func astrolabus_in_desk():
	#_astrolab_desk = GetEntity.
	pass


signal start_sanson_sleep
func sanson_sleep():
	start_sanson_sleep.emit()

func _ready() -> void:
	PuzzleManager.puzzle_ended.connect(_on_puzzle_ended)


func _on_puzzle_ended(puzzle: Puzzle):
	if puzzle is AstrolabusPuzzle:
		if puzzle.puzzle_solved:
			CharacterData.Sanson.astrolabus_aligned = true

## ================== ADDING MOODS/ANIMATIONS ===================

## to add a NEW ANIMATION, it's name MUST MATCH the name of a MOOD.

## our guiderule is that all moods should have ALL UPPERCASE names.
