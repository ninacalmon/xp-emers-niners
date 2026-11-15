extends Node3D
class_name ChurchBell

signal bell_toll

@export_range(0.3, 5.0, 0.05) var toll_interval_min: float = 2.6
@export_range(0.3, 5.0, 0.05) var toll_interval_max: float = 3.0

@onready var bell_pivot: Node3D = $BellPivot
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var audio_stream_player_3d_2: AudioStreamPlayer3D = $AudioStreamPlayer3D2
@onready var _players: Array[AudioStreamPlayer3D] = [audio_stream_player_3d, audio_stream_player_3d_2]

const DEFAULT_SETTLE_FACTORS: Array[float] = [0.35, 0.15, 0.05]
const DEFAULT_SWING_DEGREES: float = 40.0

var _settle_factors: Array[float] = DEFAULT_SETTLE_FACTORS
var _swing_angle: float = deg_to_rad(DEFAULT_SWING_DEGREES)
var _toll_times: int = 3
var _is_tolling: bool = false


func _ready() -> void:
	TimeManager.time_pass.connect(_on_time_pass)
	TimeManager.time_pass_special.connect(_on_time_pass_special)


func toll_bell_special(
		times: int,
		interval_min: float = -1.0,
		interval_max: float = -1.0,
		swing_degrees: float = -1.0,
		settle_factors: Array[float] = []
) -> void:
	if _is_tolling:
		return

	var old_interval_min: float = toll_interval_min
	var old_interval_max: float = toll_interval_max
	var old_swing_angle: float = _swing_angle
	var old_settle_factors: Array[float] = _settle_factors

	if interval_min > 0.0:
		toll_interval_min = interval_min
	if interval_max > 0.0:
		toll_interval_max = interval_max
	toll_interval_max = maxf(toll_interval_max, toll_interval_min)
	if swing_degrees > 0.0:
		_swing_angle = deg_to_rad(swing_degrees)
	if not settle_factors.is_empty():
		_settle_factors = settle_factors

	await toll_bell(times)

	toll_interval_min = old_interval_min
	toll_interval_max = old_interval_max
	_swing_angle = old_swing_angle
	_settle_factors = old_settle_factors


func toll_bell(times: int) -> void:
	_is_tolling = true
	var direction: float = -1.0

	for i: int in range(times):
		var duration: float = randf_range(toll_interval_min, toll_interval_max)
		var amplitude: float = _swing_angle * randf_range(0.92, 1.0)

		await _swing_to(amplitude * direction, duration)

		_players[i % _players.size()].play()
		direction *= -1.0

	for factor: float in _settle_factors:
		await _swing_to(_swing_angle * factor * direction, toll_interval_max)
		direction *= -1.0

	await _swing_to(0.0, toll_interval_max * 0.7)
	_is_tolling = false


func _on_time_pass(time: TimeManager.Times) -> void:
	if TimeManager.last_tolled_time == time:
		return
	if _is_tolling:
		return
	TimeManager.last_tolled_time = time

	match time:
		TimeManager.Times.at1200:
			_toll_times = 0
		TimeManager.Times.at1500:
			_toll_times = 3
		TimeManager.Times.at1800:
			_toll_times = 6
		TimeManager.Times.at2100:
			_toll_times = 9
		TimeManager.Times.at2400:
			_toll_times = 12

	toll_bell(_toll_times)


func _on_time_pass_special(special: String) -> void:
	if _is_tolling:
		return

	match special:
		"starting":
			TimeManager.last_tolled_time = TimeManager.Times.at1200
			audio_stream_player_3d.volume_db = 160
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
			#audio_stream_player_3d.volume_db = 80
			_toll_times = 10
			await toll_bell_special(_toll_times, 6, 6, 25.0, DEFAULT_SETTLE_FACTORS)
			audio_stream_player_3d.volume_db = 140
			audio_stream_player_3d.play()
			await audio_stream_player_3d.finished
			audio_stream_player_3d.volume_db = 80


func _swing_to(angle: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bell_pivot, "rotation:x", angle, duration)
	await tween.finished
