extends ActionTrigger

@export var scene_root: StaticBody3D
@export var key_item_needed: ItemRes

func trigger():
	var item: ItemRes = InventoryManager.inventory_slots[
	InventoryManager.selected_slot_idx
	]

	if item and item.id == key_item_needed.id:
		print("abrindo!!!")
		InventoryManager.use_item()
		scene_root.queue_free()
	else:
		print("não não...")
	



func ray_enter():
	pass


func ray_exit():
	pass
