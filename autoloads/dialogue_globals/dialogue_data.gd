extends Node

## this is a [Dictionary]! The first value is called a KEY,
## while the second (after :) is called VALUE.

## here, it is being used as a HASH-SET!
## that means we are using it only for it's KEYS.
## VALUES are not used. set it to true as default.

## we are using it because GdScript does not have native HASH-SETS.
## hash-sets (or dictionaries, in our case) are usefull because they
## do not allow duplicate keys and able faster and optmized search for
## keys in it.

var moods: Dictionary[String, bool] = {
	"IDLE": true,
	"HAPPY": true,
	"SAD": true,
	"ANGRY": true,
}

## ================== ADDING MOODS/ANIMATIONS ===================

## to add a NEW ANIMATION, it's name MUST MATCH the name of a MOOD.

## our guiderule is that all moods should have ALL UPPERCASE names.
## as stated before, the value of the mood should be 'true', as default.

## the animation's name must MATCH EXACTLY the name of the a mood,
## that means it should ALSO be ALL UPPERCASE.

## characters DONT have the need to contain a animation for every mood.
## they should have the animations they'll will use in dialogue.

## anyways, in the case that a line of dialogue is set with a mood
## that character dont have an animation for, it will not give errors,
## it will only fail to play it and remain with the previous playing one.
