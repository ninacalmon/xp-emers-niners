extends ActionTrigger

const ROTTEN_MEAT = preload("uid://cefbvxaw1bbrf")
var given_meat: bool = false

@onready var outline: Sprite3dOutlineShader = $Sprite3D/Outline
@onready var flies_audio_stream_player_3d: AudioStreamPlayer3D = $FliesAudioStreamPlayer3D


func _ready() -> void:
	super()
	flies_audio_stream_player_3d.play()


func trigger():
	if CharacterData.Julio.item_animals == "ink" and \
	not given_meat or CharacterData.Julio.item_animals == "plant" and \
	not CharacterData.Julio.given_meat and \
	not given_meat:
		CharacterData.Julio.given_meat = true
		given_meat = true
		InventoryManager.add_new_item(ROTTEN_MEAT)


func ray_enter():
	pass
	#if not CharacterData.Julio.item_animals == "flower":
		#outline.set_instance_shader_parameter("outline_enabled", false)


func ray_exit():
	pass
