extends Control

@export var indic_speed: float = 500.0
@export var hit_width: int = 60
@export_range(0.0, 1.0, 0.1) var full_width_percentage: float = 0.5

@onready var hit_bar_panel_cont: PanelContainer = $HitBarPanelCont
@onready var med_hit_marg: MarginContainer = $HitBarPanelCont/MedHitMarg
@onready var full_hit_marg: MarginContainer = $HitBarPanelCont/MedHitMarg/Panel/FullHitMarg
@onready var indicator_marg: MarginContainer = $HitBarPanelCont/IndicatorMarg
@onready var indicator_panel: Panel = $HitBarPanelCont/IndicatorMarg/IndicatorPanel

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

func _ready() -> void:
	hit_bar_full_width = int(hit_bar_panel_cont.size.x)
	indicator_width = indicator_panel.get_minimum_size().x
	max_value_indic = int(hit_bar_full_width - indicator_width)

	full_hit_width = int(hit_width * full_width_percentage)
	@warning_ignore("integer_division")
	full_hit_inset = (hit_width - full_hit_width) / 2

	full_hit_marg.add_theme_constant_override("margin_left", full_hit_inset)
	full_hit_marg.add_theme_constant_override("margin_right", full_hit_inset)

	randomize_hit_placement()


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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if not move_indic:
			move_indic = true
			return

		move_indic = false
		await calculate_points()
		randomize_hit_placement()
		move_indic = true


func _process(delta: float) -> void:
	if not move_indic:
		return

	_elapsed += delta * indic_speed
	value = pingpong(_elapsed, max_value_indic)
	indicator_marg.add_theme_constant_override("margin_left", int(value))


func calculate_points() -> void:
	var indicator: float = indicator_marg.get_theme_constant("margin_left") + indicator_width / 2.0

	if indicator >= full_hit_start and indicator <= full_hit_end:
		print("FULL HIT")
	elif indicator >= med_hit_start and indicator <= med_hit_end:
		print("MEDIUM HIT")
	else:
		print("FAIL")

	await get_tree().create_timer(0.5).timeout
