extends Node

signal mood_set(character_name: String, mood_name: String)

const MOODS_BY_CHARACTER: Dictionary = {
	"Julio": JulioMoods,
	"Lucio": LucioMoods,
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


func set_mood(character_name: String, mood: int) -> void:
	var moods: Dictionary = MOODS_BY_CHARACTER.get(character_name, {})
	var mood_name: Variant = moods.find_key(mood)
	if mood_name == null:
		push_warning("%s has no mood with value %d" % [character_name, mood])
		return
	mood_set.emit(character_name, str(mood_name))


## ================== ADDING MOODS/ANIMATIONS ===================

## to add a NEW ANIMATION, it's name MUST MATCH the name of a MOOD.

## our guiderule is that all moods should have ALL UPPERCASE names.
