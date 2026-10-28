extends ActionTrigger


@export var key_item: ItemRes

func trigger():
	InventoryManager.add_new_item([key_item, preload("uid://dltn5dox1dd8c")].pick_random())
	print("click")

func ray_enter():
	pass

func ray_exit():
	pass
