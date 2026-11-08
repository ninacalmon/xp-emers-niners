extends ActionTrigger

var item: ItemRes


func _ready() -> void:
	item = (get_parent() as ItemInWorld).item


func trigger() -> void:
	var added: bool = InventoryManager.add_new_item(item)
	if added:
		get_parent().queue_free()

func ray_enter():
	pass


func ray_exit():
	pass
