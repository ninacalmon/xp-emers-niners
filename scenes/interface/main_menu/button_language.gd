extends Button

@export var language_select: Control

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	language_select.show()
