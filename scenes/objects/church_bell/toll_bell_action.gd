extends ActionTrigger

@onready var church_bell: ChurchBell = $".."

func trigger():
	church_bell.toll_bell(3)
	await get_tree().create_timer(1.5).timeout
	church_bell.bell_toll.emit()


func ray_enter():
	pass



func ray_exit():
	pass
