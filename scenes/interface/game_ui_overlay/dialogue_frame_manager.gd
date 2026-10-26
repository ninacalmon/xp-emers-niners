extends Control

@onready var frame_animated_spr: AnimatedSprite2D = $FrameAnimatedSpr
@onready var player_speech_overlay_animated_spr: AnimatedSprite2D = $PlayerSpeechOverlayAnimatedSpr

var _balloon: DialogueManagerExampleBalloon

var is_player_talking: bool = false

func _ready() -> void:
	player_speech_overlay_animated_spr.hide()
	frame_animated_spr.play("default")

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	DialogueManager.balloon_started.connect(_on_balloon_started)


func _on_dialogue_started(_res: DialogueResource):
	frame_animated_spr.play("dialogue")
	await frame_animated_spr.animation_finished
	DialogueManager.ready_to_start.emit()


func _on_dialogue_ended(_res: DialogueResource):
	frame_animated_spr.play_backwards("dialogue")
	await frame_animated_spr.animation_finished
	frame_animated_spr.play("default")


func _on_balloon_started(balloon: Node):
	if balloon is DialogueManagerExampleBalloon:
		_balloon = balloon
		balloon.player_line_started.connect(_on_player_line_started)
		balloon.player_line_ended.connect(_on_player_line_ended)


func _on_player_line_started():
	if not is_player_talking:
		player_speech_overlay_animated_spr.show()
		player_speech_overlay_animated_spr.play("dialogue")
		await player_speech_overlay_animated_spr.animation_finished
	_balloon.ready_to_start.emit()
	is_player_talking = true


func _on_player_line_ended():
	player_speech_overlay_animated_spr.play_backwards("dialogue")
	await player_speech_overlay_animated_spr.animation_finished
	player_speech_overlay_animated_spr.hide()
	is_player_talking = false
