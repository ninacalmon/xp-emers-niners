## this autoload manages player's inventory.
## the items are kept in a dictionary.
extends Node

signal selected_item_changed(item: ItemRes)
signal inventory_item_changed(slot_idx: int)
signal selected_slot_changed(slot_idx: int)


var inventory_slots: Dictionary = {}

var inventory_size: int = 10

var selected_slot_idx: int = 0

var is_busy: bool = false


var selected_item: ItemRes:
	set(value):
		selected_item = value
		selected_item_changed.emit(value)


func _ready() -> void:
	for i in range(inventory_size):
		inventory_slots[i] = null


func _input(event: InputEvent) -> void:
	if is_busy:
		return

	if event.is_action_pressed("inventory_up"):
		change_slot(-1)
	elif event.is_action_pressed("inventory_down"):
		change_slot(+1)



## input controls what is the current selected slot.
func change_slot(direction: int):
	selected_slot_idx = wrapi(selected_slot_idx + direction, 0, inventory_size)
	selected_slot_changed.emit(selected_slot_idx)

	selected_item = inventory_slots[selected_slot_idx]



## this function passes by every slot on inventory, looking for the first empty spot and
## storaging the new_item inside it.
func add_new_item(new_item: ItemRes):
	for i in range(inventory_size):
		if inventory_slots[i] == null:
			inventory_slots[i] = new_item
			inventory_item_changed.emit(i)
			print("new item here: ", i)
			if i == selected_slot_idx:
				selected_item = inventory_slots[i]
			return

	## this part runs only if no avaiable slot were found.
	## NOTE: later, we need to give a proper feedback in the game!
	print("sem espaço no inventário.")


func use_item():
	var item: ItemRes = inventory_slots[selected_slot_idx]

	if item.permanent:
		return

	discard(selected_slot_idx)


func discard(slot_idx: int):
	if inventory_slots[slot_idx] == null:
		return

	inventory_slots[slot_idx] = null
	inventory_item_changed.emit(slot_idx)

	if slot_idx == selected_slot_idx:
		selected_item = inventory_slots[slot_idx]


func tried_wrong_item():
	pass
