class_name TaskLabel
extends Control


@onready var task_button: Button = $TaskButton
@onready var rich_text_label: RichTextLabel = $TaskButton/MarginContainer/RichTextLabel




var open_width = -240.0
var closed_width = 0

var is_open: bool = false

func open():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(task_button, "offset_left", open_width, 0.4)
	await tween.finished

	is_open = true



func close():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(task_button, "offset_left", closed_width, 0.4)
	await tween.finished

	is_open = false
