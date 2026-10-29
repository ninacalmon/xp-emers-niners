extends CanvasLayer

@onready var focus_playground_slot: Control = $FocusPlaygroundSlot


func _ready():
	var focus_playground: FocusPlayground = get_node("/root/FocusPlayground")
	focus_playground.attach_to_slot.call_deferred(focus_playground_slot)
