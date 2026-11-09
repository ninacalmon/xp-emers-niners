extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)
	await get_tree().create_timer(5).timeout
	FadeInOut.fade_out()


func _on_pressed():
	LoadingManager.load_scene("res://scenes/world/world_cutscene.tscn")
