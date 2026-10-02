extends ActionTrigger

@export var scene_root: StaticBody3D
@export var key_item_needed: ItemRes

func trigger():
	var item: ItemRes = InventoryManager.inventory_slots\
	[
	InventoryManager.selected_slot_idx
	]

	if item and item.id == key_item_needed.id:
		print("you have the key! i will open")
		InventoryManager.use_item()

		if scene_root:
			scene_root.queue_free()
	else:
		print("no... f you")


func ray_enter():
	pass


func ray_exit():
	pass
