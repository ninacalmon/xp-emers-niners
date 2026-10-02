## ItemRes's porpose is only to storage item's core info. It is completely
## customizable through the inspector.[br]
##[br]
## to create a new ItemRes, find the correct folder (currently, res://resources/itens), click
## CREATE NEW -> Resource. then, search for ItemRes, create, and customize it.[br]
##[br]
## NOTE: [Resource] is a different kind of datatype. i recommend briefly reading about it.[br]

class_name ItemRes
extends Resource

## id is the name of the item. it should be all lower-case, and spaces should be replaced with '_'
@export var id: StringName

## permanent means that the item can be used without being immediatly deleted after
@export var permanent: bool

## texture will be the [Texture2D] used in the inventory UI and also as sprite in the game world.
@export var texture: Texture2D
