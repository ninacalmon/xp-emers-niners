extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	LoadingManager.load_scene("res://scenes/world/test_world.tscn")
