extends ActionTrigger


@export var key_item: ItemRes

func trigger():
	InventoryManager.add_new_item(key_item)

func ray_enter():
	pass

func ray_exit():
	pass
