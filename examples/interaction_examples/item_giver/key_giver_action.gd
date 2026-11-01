extends ActionTrigger


@export var key_item: ItemRes

func trigger():
	InventoryManager.add_new_item(preload("uid://3c0ta31odhc6"))
	InventoryManager.add_new_item(preload("uid://8dvrkoxmyyx4"))


func ray_enter():
	pass

func ray_exit():
	pass
