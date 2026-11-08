extends ItemFocusView


############################ Drink Logic #######################################

const MIN_X_DEGREES: float = 80.0
const YZ_TOLERANCE_DEGREES: float = 5.0

var drinked: bool = false
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var rich_text_label: RichTextLabel = $SubViewport/RichTextLabel


func _process(_delta: float) -> void:
	if not is_active:
		return

	if Input.is_action_pressed("focus_rotate_item"):
		var rot: Vector3 = item_mesh.rotation_degrees
		var x_reached: bool = rot.x > MIN_X_DEGREES
		var yz_similar: bool = absf(rot.y - rot.z) <= YZ_TOLERANCE_DEGREES

		if x_reached and yz_similar:
			if not drinked:
				drinked = true
				drink()


func drink():
	print("DRINKING")
	audio_stream_player.play()
	fade(rich_text_label)

	GetEntity.get_player().get_drunk()


func fade(node: Node):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.8)
