extends Node

signal mood_set(character_name: String, mood_name: String)

const MOODS_BY_CHARACTER: Dictionary = {
	"Julio": JulioMoods,
	"Lucio": LucioMoods,
	"Hugo": HugoMoods
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


enum SansonMoods {}

enum ConfessorMoods {
	VARIATION
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
