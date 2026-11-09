extends ActionTrigger


const ASTROLABUS_FULL = preload("uid://c6akotlps2yoe")
const DRINK = preload("uid://bugvpvu1atehq")
const FLOWER = preload("uid://dltn5dox1dd8c")
const INKWELL = preload("uid://s1b5gx6p2rg1")
const MEDICATION = preload("uid://bkc7dx8duiasn")
const TOXIC_PLANT = preload("uid://dmi136l0r18xj")
const ROTTEN_MEAT = preload("uid://cefbvxaw1bbrf")
const MIRROR_A_FULL = preload("uid://cka13d4wlnvfr")
const MIRROR_B_FULL = preload("uid://dymw8vckx5n6n")
const MIRROR_C_FULL = preload("uid://bsdb5amilihps")
const CANDLE = preload("uid://koxeqrufqjyl")
const LOCKPICK = preload("uid://cb0fdb2g5cmw2")

@export var key_item: ItemRes

var itens: Array[ItemRes] = [
	ASTROLABUS_FULL,
	DRINK,
	FLOWER,
	INKWELL,
	MEDICATION,
	TOXIC_PLANT,
	ROTTEN_MEAT,
	MIRROR_A_FULL,
	MIRROR_B_FULL,
	MIRROR_C_FULL,
	CANDLE,
	LOCKPICK,
]

func trigger() -> void:
	itens.reverse()
	for item: ItemRes in itens:
		InventoryManager.add_new_item(item)



func ray_enter():
	pass

func ray_exit():
	pass
