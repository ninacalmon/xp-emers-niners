## this class manages [InventorySlot]s. It gets and modifies
## data in the autoload [InventoryManager].
class_name InventoryUI
extends VBoxContainer

@export var inventory_slot_ui_scene: PackedScene

var slots: Array[InventorySlot]

var selected_slot_idx: int = 0

func _ready() -> void:
	InventoryManager.inventory_item_changed.connect(_on_inventory_item_changed)
	InventoryManager.selected_slot_changed.connect(_on_selected_slot_changed)

	setup_slots()

	slots[InventoryManager.selected_slot_idx].button_pressed = true

## storages and asserts that the number of slots is no greater or lower 
## then whats defined on [InventoryManager].
func setup_slots():
	for s in get_children():
		if s is InventorySlot:
			slots.append(s)

	while len(slots) > InventoryManager.inventory_size:
		slots.pop_at(-1)
	while len(slots) < InventoryManager.inventory_size:
		var new_slot = inventory_slot_ui_scene.instantiate()
		add_child(new_slot)
		slots.append(new_slot)


func _on_inventory_item_changed(slot_idx: int):
	slots[slot_idx].item = InventoryManager.inventory_slots[slot_idx]


func _on_selected_slot_changed(slot_idx: int):
	slots[slot_idx].button_pressed = true
