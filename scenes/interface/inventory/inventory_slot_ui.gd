@tool ## @tool means this script has code that runs in the editor
## (without the need to start the game per se).[br]
## [br]
## this code runs both in the editor and in the game itself.
class_name InventorySlot
extends Node

const SHOW_DELAY: float = 0.5
const FADE_DURATION: float = 0.2
const VISIBLE_DURATION: float = 3.0

const SHAKE_OFFSET: float = 8.0
const SHAKE_STEP: float = 0.04

@onready var button_slot: Button = $HBoxContainer/ButtonSlot
@onready var center_container: CenterContainer = $HBoxContainer/ButtonSlot/CenterContainer
@onready var item_texture: TextureRect = $HBoxContainer/ButtonSlot/CenterContainer/ItemTexture
@onready var rich_text_label: RichTextLabel = $HBoxContainer/RichTextLabel

var _label_tween: Tween

var _shake_tween: Tween
var _shake_origin: Vector2


@export var item: ItemRes:
	set(value):
		item = value
		update_slot()

func update_slot():
	if item:
		item_texture.texture = item.texture
		if button_slot.button_pressed:
			_show_label()
	else:
		item_texture.texture = null


func shake_slot() -> void:
	if _shake_tween != null and _shake_tween.is_valid():
		_shake_tween.kill()
	center_container.position = _shake_origin

	_shake_tween = create_tween()
	_shake_tween.tween_property(center_container, "position", _shake_origin + Vector2(SHAKE_OFFSET, 0.0), SHAKE_STEP)
	_shake_tween.tween_property(center_container, "position", _shake_origin + Vector2(-SHAKE_OFFSET, 0.0), SHAKE_STEP)
	_shake_tween.tween_property(center_container, "position", _shake_origin + Vector2(SHAKE_OFFSET, 0.0), SHAKE_STEP)
	_shake_tween.tween_property(center_container, "position", _shake_origin + Vector2(-SHAKE_OFFSET, 0.0), SHAKE_STEP)
	_shake_tween.tween_property(center_container, "position", _shake_origin, SHAKE_STEP)


func _ready() -> void:
	_shake_origin = center_container.position
	button_slot.toggled.connect(_on_button_slot_toggled)
	rich_text_label.modulate.a = 1.0 if button_slot.button_pressed else 0.0


func _on_button_slot_toggled(toggled_on: bool) -> void:
	if FocusPlayground.is_focused:
		return

	if toggled_on and item:
		_show_label()
	else:
		_hide_label()


func _show_label() -> void:
	_kill_label_tween()

	var current_alpha: float = rich_text_label.modulate.a
	var fade_in_distance: float = 1.0 - current_alpha

	_label_tween = create_tween()
	_label_tween.tween_interval(SHOW_DELAY)
	_label_tween.tween_property(rich_text_label, "modulate:a", 1.0, FADE_DURATION * fade_in_distance)
	_label_tween.tween_interval(VISIBLE_DURATION)
	_label_tween.tween_property(rich_text_label, "modulate:a", 0.0, FADE_DURATION)


func _hide_label() -> void:
	_kill_label_tween()

	var current_alpha: float = rich_text_label.modulate.a

	_label_tween = create_tween()
	_label_tween.tween_property(rich_text_label, "modulate:a", 0.0, FADE_DURATION * current_alpha)


func _kill_label_tween() -> void:
	if _label_tween != null and _label_tween.is_valid():
		_label_tween.kill()
