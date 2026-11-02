extends ActionTrigger


@export var key_item: ItemRes

func trigger():
	InventoryManager.add_new_item(preload("uid://3c0ta31odhc6"))
	InventoryManager.add_new_item(preload("uid://8dvrkoxmyyx4"))
	InventoryManager.add_new_item(preload("uid://koxeqrufqjyl"))
	InventoryManager.add_new_item(preload("uid://s1b5gx6p2rg1"))
	InventoryManager.add_new_item(preload("uid://dltn5dox1dd8c"))
	InventoryManager.add_new_item(MEDICATION)
	InventoryManager.add_new_item(LOCKPICK)
	InventoryManager.add_new_item(ROTTEN_MEAT)
	InventoryManager.add_new_item(DRINK)


func ray_enter():
	pass

func ray_exit():
	pass


const MEDICATION = preload("uid://bkc7dx8duiasn")
const LOCKPICK = preload("uid://cb0fdb2g5cmw2")
const ROTTEN_MEAT = preload("uid://cefbvxaw1bbrf")
const DRINK = preload("uid://bugvpvu1atehq")
