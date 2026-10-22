class_name InteractionOverlay
extends Control


@export var interaction_text: RichTextLabel

var _current_action: ActionTrigger = null
var _displayed_key: String = ""


func _ready() -> void:
	InventoryManager.selected_item_changed.connect(_on_selected_item_changed)


func show_inter_text(action: ActionTrigger) -> void:
	_current_action = action
	_refresh()


func hide_inter_text() -> void:
	_current_action = null
	_refresh()


func _on_selected_item_changed(_item: ItemRes) -> void:
	_refresh()


func _refresh() -> void:
	var item: ItemRes = InventoryManager.selected_item
	var should_show: bool = (
		_current_action != null
		and _current_action.item_interaction
		and item != null
	)

	if not should_show:
		_displayed_key = ""
		interaction_text.hide()
		return

	var key: String = item.name_tr_key
	if key != _displayed_key:
		_displayed_key = key
		interaction_text.text = "Utilizar %s" % tr(key)
	interaction_text.show()
