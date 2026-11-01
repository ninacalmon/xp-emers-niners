extends ActionTrigger


@export var key_item: ItemRes

func trigger():
	InventoryManager.add_new_item(preload("uid://3c0ta31odhc6"))
	InventoryManager.add_new_item(preload("uid://8dvrkoxmyyx4"))
	InventoryManager.add_new_item(preload("uid://koxeqrufqjyl"))
	InventoryManager.add_new_item(preload("uid://s1b5gx6p2rg1"))
	InventoryManager.add_new_item(preload("uid://dltn5dox1dd8c"))
	InventoryManager.add_new_item(MEDICATION)


func ray_enter():
	pass

func ray_exit():
	pass


const MEDICATION = preload("uid://bkc7dx8duiasn")
