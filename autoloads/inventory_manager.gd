## this autoload manages player's inventory.
## the items are kept in a dictionary.
extends Node


signal inventory_item_changed(slot_idx: int)

var inventory_slots: Dictionary = {
	0 : null,
	1 : null,
	2 : null,
	3 : null
}

var inventory_size: int = 4

var selected_slot_idx: int = 0


## this function passes by every slot on inventory, looking for the first empty spot and
## storaging the new_item inside it.
func add_new_item(new_item: ItemRes):
	for i in range(inventory_size):
		if inventory_slots[i] == null:
			inventory_slots[i] = new_item
			inventory_item_changed.emit(i)
			print("new item here: ", i)
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
