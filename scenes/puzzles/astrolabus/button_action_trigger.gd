class_name ButtonActionTrigger
extends ActionTrigger


signal button_pressed
signal button_released

var block_press: bool = false
var _is_pressed: bool = false

func trigger():
	if block_press:
		return

	_is_pressed = true
	button_pressed.emit()


func ray_enter():
	pass


func ray_exit():
	pass


func _input(event: InputEvent) -> void:
	if not _is_pressed:
		return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_is_pressed = false
			button_released.emit()
