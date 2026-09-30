@abstract
## @abstract class to inherit from. can (hopefully) be used for a variety of 
## different interaction types.[br]
##[br]
## WARNING: do NOT edit this class unless the change is needed in ALL of it's 
class_name ActionTrigger
extends Node

@abstract
func trigger()

@abstract
func ray_enter()

@abstract
func ray_exit()
