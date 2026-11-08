extends Node

@export var track_a: AudioStream
@export var track_b: AudioStream
@export var volume_a: float = -22
@export var volume_b: float = -30
@export var min_delay: float = 30.0 
@export var max_delay: float = 90.0

var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _play_a: bool = true

var _first_play: bool = true

func _ready() -> void:
	add_child(_player)
	_player.finished.connect(_schedule_next)
	_schedule_next()


func _schedule_next() -> void:
	if not _first_play:
		await get_tree().create_timer(randf_range(min_delay, max_delay)).timeout
	else:
		_first_play = false
	_player.stream = track_a if _play_a else track_b
	_player.volume_db = volume_a if _play_a else volume_b
	_player.play()
	_play_a = not _play_a
