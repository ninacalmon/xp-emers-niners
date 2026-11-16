extends ActionTrigger

var is_layed: bool = false
@export var phantom_camera_3d: PhantomCamera3D

func trigger():
	if is_layed:
		return

	is_layed = true
	sit_down()


func ray_enter():
	pass


func ray_exit():
	pass


func sit_down():
	phantom_camera_3d.priority = 1000
	var p: Player = GetEntity.get_player()
	p.is_cutscene_locked = true


func get_up():
	phantom_camera_3d.priority = -1
	var p: Player = GetEntity.get_player()
	p.is_cutscene_locked = false


func _ready() -> void:
	super()

	force_outline_off = true


func _input(event: InputEvent) -> void:
	if not is_layed:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		is_layed = false
		get_up()
