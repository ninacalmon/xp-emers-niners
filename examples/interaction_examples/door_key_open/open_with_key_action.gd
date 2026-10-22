extends ActionTrigger

@export var scene_root: StaticBody3D
@export var key_item_needed: ItemRes


func _ready() -> void:
	super()

func trigger():
	TaskManager.give_task("open_door", "Encontre algo para abrir a mega porta.")
	var item: ItemRes = \
	InventoryManager.inventory_slots[InventoryManager.selected_slot_idx]


	if item:
		if item.id == key_item_needed.id:
			TaskManager.complete_task("open_door")
			print("you have the key! i will open")
			InventoryManager.use_item()

			if scene_root:
				scene_root.queue_free()

		else:
			InventoryManager.tried_wrong_item()


func ray_enter():
	pass


func ray_exit():
	pass
