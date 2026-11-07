class_name ItemInWorld
extends Node3D

signal picked_up

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var collision_shape_3d: CollisionShape3D = $InteractionArea/CollisionShape3D

@export var item: ItemRes

@export var deactivate: bool = false:
	set(value):
		deactivate = value
		update()


func _ready() -> void:
	update()


func update() -> void:
	if not is_node_ready():
		return
	
	collision_shape_3d.set_deferred("disabled", deactivate)
