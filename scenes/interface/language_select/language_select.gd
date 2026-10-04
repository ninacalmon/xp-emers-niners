extends Control

@onready var button_en: Button = $PanelContainer/VBoxContainer/ButtonEN
@onready var button_pt: Button = $PanelContainer/VBoxContainer/ButtonPT


func _ready() -> void:
	button_en.pressed.connect(_on_button_en_pressed)
	button_pt.pressed.connect(_on_button_pt_pressed)

	## I prefer to test the game in english but this is because i am dumb! vvv
	TranslationServer.set_locale("en")
	hide()


func _on_button_en_pressed():
	TranslationServer.set_locale("en")
	hide()


func _on_button_pt_pressed():
	TranslationServer.set_locale("pt")
	hide()
