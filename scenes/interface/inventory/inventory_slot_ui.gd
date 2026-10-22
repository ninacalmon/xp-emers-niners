@tool ## @tool means this script has code that runs in the editor
## (without the need to start the game per se).[br]
## [br]
## this code runs both in the editor and in the game itself.
class_name InventorySlot
extends Button

@onready var item_texture: TextureRect = $CenterContainer/ItemTexture
@onready var center_container: CenterContainer = $CenterContainer


@export var item: ItemRes:
	set(value):
		item = value
		update_slot()


func update_slot():
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null


func shake_slot() -> void:
	var origin: Vector2 = center_container.position
	var tween: Tween = create_tween()
	tween.tween_property(center_container, "position", origin + Vector2(8, 0), 0.04)
	tween.tween_property(center_container, "position", origin + Vector2(-8, 0), 0.04)
	tween.tween_property(center_container, "position", origin + Vector2(8, 0), 0.04)
	tween.tween_property(center_container, "position", origin + Vector2(-8, 0), 0.04)
	tween.tween_property(center_container, "position", origin, 0.04)
