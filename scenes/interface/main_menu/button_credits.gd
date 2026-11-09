extends Button
@onready var rich_text_label: RichTextLabel = $"../../RichTextLabel"


func _ready() -> void:
	rich_text_label.hide()
	button_down.connect(func(): rich_text_label.show())
	button_up.connect(func(): rich_text_label.hide())
