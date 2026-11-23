extends ActionTrigger

@export var door_to_open: OpenDoorAction

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var lever: MeshInstance3D = $Sketchfab_Scene/Sketchfab_model/fb5ae766491e42f4b6bf9021e076b5b0_fbx/Object_2/RootNode/pCube7/polySurface5/polySurface5_aiStandardSurface1_0


var is_down: bool = false

func _ready() -> void:
	super()
	lever.rotation.x = deg_to_rad(-70)


func trigger():
	if is_down:
		return

	play_anim()
	door_to_open.locked = false
	door_to_open.open_door()


func ray_enter():
	pass


func ray_exit():
	pass


func play_anim():
	audio_stream_player.play()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(lever, "rotation:x", 0.0, 0.8).from(deg_to_rad(-70))
