extends Control

@onready var frame_animated_spr: AnimatedSprite2D = $FrameAnimatedSpr
@onready var player_speech_overlay_animated_spr: AnimatedSprite2D = $PlayerSpeechOverlayAnimatedSpr
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var _balloon: DialogueManagerExampleBalloon
var _overlay_token: int = 0

var is_player_talking: bool = false


func _ready() -> void:
	rich_text_label.hide()
	player_speech_overlay_animated_spr.hide()
	frame_animated_spr.play("default")

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.balloon_started.connect(_on_balloon_started)


func _on_dialogue_started(_res: DialogueResource) -> void:
	frame_animated_spr.play("dialogue")
	await frame_animated_spr.animation_finished
	DialogueManager.ready_to_start.emit()
	rich_text_label.show()


func _on_dialogue_ended(_res: DialogueResource) -> void:
	rich_text_label.hide()
	_close_player_overlay()
	frame_animated_spr.play_backwards("dialogue")
	await frame_animated_spr.animation_finished
	frame_animated_spr.play("default")


func _on_balloon_started(balloon: Node) -> void:
	if balloon is DialogueManagerExampleBalloon:
		_balloon = balloon as DialogueManagerExampleBalloon
		_balloon.player_line_started.connect(_on_player_line_started)
		_balloon.player_line_ended.connect(_on_player_line_ended)


func _on_player_line_started() -> void:
	_overlay_token += 1
	var token: int = _overlay_token

	if not is_player_talking:
		is_player_talking = true
		player_speech_overlay_animated_spr.show()
		player_speech_overlay_animated_spr.play("dialogue")
		await player_speech_overlay_animated_spr.animation_finished

	if token == _overlay_token and is_instance_valid(_balloon):
		_balloon.ready_to_start.emit()


func _on_player_line_ended() -> void:
	_close_player_overlay()


func _close_player_overlay() -> void:
	if not is_player_talking:
		return
	is_player_talking = false
	_overlay_token += 1
	var token: int = _overlay_token

	player_speech_overlay_animated_spr.play_backwards("dialogue")
	await player_speech_overlay_animated_spr.animation_finished

	if token == _overlay_token:
		player_speech_overlay_animated_spr.hide()
