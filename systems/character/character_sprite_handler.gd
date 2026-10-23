## this script handles all sprite/animation related changes
## in all characters (to be considered a character, it MUST have dialogue).
class_name CharacterSpriteHandler
extends Node

@export var bounce_duration: float = 0.1
@export var animated_sprite: AnimatedSprite2D
@export var dialogue_action: DialogueAction

var dialogue_res: DialogueResource
var original_sprite_scale: Vector2
var character_name: String = ""

func _ready() -> void:
	character_name = dialogue_action.character_name
	dialogue_res = dialogue_action.dialogue_res
	original_sprite_scale = animated_sprite.scale
	connect_signals()
	DialogueData.mood_set.connect(_on_mood_set)

	change_anim("idle")


## this function is called when a line of dialogue have a mood different than
## the previous storaged mood in [DialogueAction].
func _on_mood_set(speaker: String, mood_name: String) -> void:
	if speaker != character_name:
		return
	change_anim(mood_name)


func _on_dialogue_ended() -> void:
	change_anim("idle")


## tries to match and play animation with the same name as a mood declared
## in [DialogueData.moods].
## NOTE: to add and play a new animation/mood, read [DialogueData]!!!
func change_anim(mood: String):
	if mood == "idle":
		animated_sprite.play(mood)
		animated_sprite.stop()
		return

	if animated_sprite.sprite_frames.has_animation(mood):
		animated_sprite.play(mood)
		bounce_on_it()


func bounce_on_it():
	var tall_scale: Vector2 = Vector2(
		original_sprite_scale.x * (0.93),
		original_sprite_scale.y * (1.05)
		)

	var short_scale: Vector2 = Vector2(
		original_sprite_scale.x * (1.05),
		original_sprite_scale.y * (0.93)
		)

	var bounce_tween = create_tween()
	bounce_tween.set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(animated_sprite, "scale", tall_scale, bounce_duration)
	bounce_tween.tween_property(animated_sprite, "scale", short_scale, bounce_duration)
	bounce_tween.tween_property(animated_sprite, "scale", original_sprite_scale, bounce_duration)


func _on_ray_enter():
	pass


func _on_ray_exit():
	pass


func _on_dialogue_started():
	pass


func _on_next_dialogue():
	animated_sprite.play()


func _on_speech_line_finished():
	animated_sprite.stop()


func connect_signals():
	dialogue_action.ray_entered.connect(_on_ray_enter)
	dialogue_action.ray_exited.connect(_on_ray_exit)
	dialogue_action.dialogue_started.connect(_on_dialogue_started)
	dialogue_action.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_action.next_dialogue.connect(_on_next_dialogue)
	dialogue_action.speech_line_finished.connect(_on_speech_line_finished)
