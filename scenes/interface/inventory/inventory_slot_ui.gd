@tool ## @tool means this script has code that runs in the editor
## (without the need to start the game per se).[br]
## [br]
## this code runs both in the editor and in the game itself.
class_name InventorySlot
extends Button

@onready var item_texture: TextureRect = $CenterContainer/ItemTexture


@export var item: ItemRes:
	set(value):
		item = value
		update_slot()


func update_slot():
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null
