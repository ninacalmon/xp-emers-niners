@abstract
## @abstract class to inherit from. can (hopefully) be used for a variety of 
## different interaction types.[br]
##[br]
## WARNING: do NOT edit this class unless the change is needed in ALL of it's 
## child classes.

## NOTE: @abstract is used to enforce that a child class has all of the
## functions below implemented.

## ATTENTION: check ["res://examples/change_color_action.gd"] for an example on
## how to implement a child_class.

class_name ActionTrigger
extends Node

var hands_overlay: HandsOverlay


func _ready() -> void:
	if get_tree().get_first_node_in_group("hands_overlay") is HandsOverlay:
		hands_overlay = get_tree().get_first_node_in_group("hands_overlay")

## is called by [InteractionArea] when player actively interacts with object.
@abstract func trigger()




## is called by [InteractionArea] when player is close enough and looks
## directly at object.
@abstract func ray_enter()




## is called by [InteractionArea] when player is not close enough anymore or looked away.
@abstract func ray_exit()
