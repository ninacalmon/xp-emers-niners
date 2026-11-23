class_name LockpickQTE
extends Control

enum Result { SUCCESS, FAILED, CANCELLED }

signal progress_changed(points: int, misses: int)
signal finished(result: Result)

@export var indic_speed: float = 400.0
@export var hit_width: int = 60
@export_range(0.0, 1.0, 0.1) var full_width_percentage: float = 0.5
@export_group("Visual Feedback")
@export var shake_intensity: float = 8.0
@export var shake_duration: float = 0.25

var _shake_tween: Tween
var _original_position: Vector2

@onready var hit_bar_panel_cont: PanelContainer = $HitBarPanelCont
@onready var med_hit_marg: MarginContainer = $HitBarPanelCont/MedHitMarg
@onready var full_hit_marg: MarginContainer = $HitBarPanelCont/MedHitMarg/Panel/FullHitMarg
@onready var indicator_marg: MarginContainer = $HitBarPanelCont/IndicatorMarg
@onready var indicator_panel: Panel = $HitBarPanelCont/IndicatorMarg/IndicatorPanel
@onready var audio_stream_player_fail: AudioStreamPlayer = $AudioStreamPlayerFail
@onready var audio_stream_player_open: AudioStreamPlayer = $AudioStreamPlayerOpen

var points_to_open: int = 5
var max_misses: int = 3

var points: int = 0
var misses: int = 0

var move_indic: bool = false
var max_value_indic: int = 0
var indicator_width: float = 0.0

var value: float = 0.0
var _elapsed: float = 0.0

var hit_bar_full_width: int = 0
var full_hit_width: int = 0
var full_hit_inset: int = 0

var full_hit_start: int = 0
var full_hit_end: int = 0
var med_hit_start: int = 0
var med_hit_end: int = 0

var _start_at_right: bool = false
var _active: bool = false
var _input_enabled: bool = false
var _resolving: bool = false


func _ready() -> void:
	add_to_group("lockpick_qte")
	hide()
	_original_position = hit_bar_panel_cont.position


func run(p_points_to_open: int = points_to_open, p_max_misses: int = 3) -> Result:
	points_to_open = p_points_to_open
	max_misses = p_max_misses
	points = 0
	misses = 0
	move_indic = false
	_resolving = false
	_input_enabled = false
	_start_at_right = false
	_active = true

	show()
	await get_tree().process_frame # wait for the layout to be ready
	_setup_bar()
	randomize_hit_placement()
	progress_changed.emit(points, misses)

	move_indic = true # starts running by itself

	# grace time: the click that opened the QTE must not count as a hit
	await get_tree().create_timer(0.25).timeout
	if not _active:
		return Result.CANCELLED

	_input_enabled = true
	return await finished


func _input(event: InputEvent) -> void:
	if not _active or not _input_enabled or _resolving:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		await _resolve_hit()


func cancel() -> void:
	if _active:
		_finish(Result.CANCELLED)


func _finish(result: Result) -> void:
	var adp: AudioStreamPlayer
	if result:
		adp = audio_stream_player_open
	else:
		adp = audio_stream_player_fail
	adp.play()
	await adp.finished

	_active = false
	_input_enabled = false
	_resolving = false
	move_indic = false
	hide()
	finished.emit(result)


func _setup_bar() -> void:
	hit_bar_full_width = int(hit_bar_panel_cont.size.x)
	indicator_width = indicator_panel.get_minimum_size().x
	max_value_indic = int(hit_bar_full_width - indicator_width)

	full_hit_width = int(hit_width * full_width_percentage)
	@warning_ignore("integer_division")
	full_hit_inset = (hit_width - full_hit_width) / 2

	full_hit_marg.add_theme_constant_override("margin_left", full_hit_inset)
	full_hit_marg.add_theme_constant_override("margin_right", full_hit_inset)


func randomize_hit_placement() -> void:
	var r: int = max_value_indic if _start_at_right else 0
	_start_at_right = not _start_at_right

	indicator_marg.add_theme_constant_override("margin_left", r)
	_elapsed = r

	var left: int = randi_range(0, hit_bar_full_width - hit_width)
	var right: int = hit_bar_full_width - left - hit_width
	med_hit_marg.add_theme_constant_override("margin_left", left)
	med_hit_marg.add_theme_constant_override("margin_right", right)

	med_hit_start = left
	med_hit_end = left + hit_width

	full_hit_start = med_hit_start + full_hit_inset
	full_hit_end = med_hit_end - full_hit_inset




func _process(delta: float) -> void:
	if not move_indic:
		return

	_elapsed += delta * indic_speed
	value = pingpong(_elapsed, max_value_indic)
	indicator_marg.add_theme_constant_override("margin_left", int(value))


func _resolve_hit() -> void:
	_resolving = true
	move_indic = false

	var indicator: float = indicator_marg.get_theme_constant("margin_left") + indicator_width / 2.0

	if indicator >= full_hit_start and indicator <= full_hit_end:
		points += 3
	elif indicator >= med_hit_start and indicator <= med_hit_end:
		points += 2
		shake(2.0)
	else:
		misses += 1
		points = maxi(points - 1, 0)
		audio_stream_player_fail.play()
		shake()

	progress_changed.emit(points, misses)

	await get_tree().create_timer(0.3).timeout
	if not _active: # cancelled while waiting
		return

	if points >= points_to_open:
		_finish(Result.SUCCESS)
		return
	if misses >= max_misses:
		_finish(Result.FAILED)
		return

	randomize_hit_placement()
	move_indic = true
	_resolving = false


func shake(intensity: float = -1.0) -> void:
	if intensity < 0.0:
		intensity = shake_intensity

	if _shake_tween and _shake_tween.is_running():
		_shake_tween.kill()

	hit_bar_panel_cont.position = _original_position

	_shake_tween = create_tween()

	for i in range(5):
		var strength: float = intensity * (1.0 - float(i) / 5.0)
		var offset: float = randf_range(-strength, strength)

		_shake_tween.tween_property(
			hit_bar_panel_cont,
			"position:x",
			_original_position.x + offset,
			shake_duration / 10.0
		)

	_shake_tween.tween_property(
		hit_bar_panel_cont,
		"position",
		_original_position,
		shake_duration * 0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
