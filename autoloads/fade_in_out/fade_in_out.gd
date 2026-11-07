extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

var _tween: Tween = null


func _ready() -> void:
	layer = 99
	color_rect.color = Color.BLACK
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0.0
	color_rect.visible = false
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func fade_in(duration: float = 0.5) -> void:
	await _fade_to(1.0, duration)


func fade_out(duration: float = 0.5) -> void:
	await _fade_to(0.0, duration)

func change_scene_to(scene: String, dur_in: float = 1.0, dur_out: float = 1.0):
	await fade_in(dur_in)
	LoadingManager.load_scene(scene)
	await  get_tree().create_timer(2.0).timeout
	fade_out(dur_out)

func _fade_to(target_alpha: float, duration: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	color_rect.visible = true

	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	_tween = create_tween()
	_tween.tween_property(color_rect, "modulate:a", target_alpha, duration)
	await _tween.finished

	if is_zero_approx(target_alpha):
		color_rect.visible = false
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
