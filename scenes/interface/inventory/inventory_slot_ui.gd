@tool
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
