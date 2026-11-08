extends Node3D
class_name ChurchBell

signal bell_toll

@export_range(0.3, 5.0, 0.05) var toll_interval_min: float = 1.5
@export_range(0.3, 5.0, 0.05) var toll_interval_max: float = 2.3

@onready var bell_pivot: Node3D = $BellPivot
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_stream_player_3d_2: AudioStreamPlayer3D = $AudioStreamPlayer3D2
@onready var _players: Array[AudioStreamPlayer3D] = [audio_stream_player_3d, audio_stream_player_3d_2]

const SETTLE_FACTORS: Array[float] = [0.35, 0.15, 0.05]

var _swing_angle: float = deg_to_rad(40.0)
var _toll_times: int = 3


func _ready() -> void:
	TimeManager.time_pass.connect(_on_time_pass)


func _on_time_pass(time: TimeManager.Times) -> void:
	if TimeManager.last_tolled_time == time:
		return
	TimeManager.last_tolled_time = time

	match time:
		TimeManager.Times.at1200:
			_toll_times = 12
		TimeManager.Times.at1500:
			_toll_times = 3
		TimeManager.Times.at1800:
			_toll_times = 6
		TimeManager.Times.at2100:
			_toll_times = 9
		TimeManager.Times.at2400:
			_toll_times = 12

	toll_bell(_toll_times)


func toll_bell(times: int) -> void:
	var direction: float = -1.0

	for i: int in range(times):
		var duration: float = randf_range(toll_interval_min, toll_interval_max)
		var amplitude: float = _swing_angle * randf_range(0.92, 1.0)

		await _swing_to(amplitude * direction, duration)

		_players[i % _players.size()].play()
		direction *= -1.0

	for factor: float in SETTLE_FACTORS:
		await _swing_to(_swing_angle * factor * direction, toll_interval_max)
		direction *= -1.0

	await _swing_to(0.0, toll_interval_max * 0.7)


func _swing_to(angle: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bell_pivot, "rotation:x", angle, duration)
	await tween.finished
