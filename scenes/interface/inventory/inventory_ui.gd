extends HBoxContainer


var slots: Array[InventorySlot]

var selected_slot_idx: int = 0

func _ready() -> void:
	InventoryManager.inventory_item_changed.connect(_on_inventory_item_changed)

	setup_slots()


func setup_slots():
	for s in get_children():
		if s is InventorySlot:
			slots.append(s)

	while len(slots) > InventoryManager.inventory_size:
		slots.pop_at(-1)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_up"):
		change_slot(-1)
	elif event.is_action_pressed("inventory_down"):
		change_slot(+1)


func change_slot(direction: int):
	selected_slot_idx = wrapi(selected_slot_idx + direction, 0, len(slots))
	InventoryManager.selected_slot_idx = selected_slot_idx

	print(selected_slot_idx)
	slots[selected_slot_idx].button_pressed = true


func _on_inventory_item_changed(slot_idx: int):
	print("item changed")
	slots[slot_idx].item = InventoryManager.inventory_slots[slot_idx]
	print("my slot: ", slot_idx, " the item: ", InventoryManager.inventory_slots[slot_idx])
