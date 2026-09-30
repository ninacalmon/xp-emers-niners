class_name CloseArea
extends Area3D

signal player_near
signal player_far

func _ready() -> void:
	body_entered.connect(_on_area_entered)
	body_exited.connect(_on_area_exited)


func _on_area_entered(body: Node3D):
	if body is Player:
		print("near")
		player_near.emit()


func _on_area_exited(body: Node3D):
	if body is Player:
		print("far")
		player_far.emit()
