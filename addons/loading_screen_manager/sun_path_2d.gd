extends Path2D

@onready var path_follow_2d: PathFollow2D = $PathFollow2D


@export var speed: float = 1500.0

func _process(delta: float) -> void:
	path_follow_2d.progress += speed * delta
