extends Control

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioManager.play_music(music)
