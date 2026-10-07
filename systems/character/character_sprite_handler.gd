## this script handles all sprite/animation related changes
## in all characters (to be considered a character, it MUST have dialogue).
class_name CharacterSpriteHandler
extends Node

@export var bounce_duration: float = 0.1
@export var animated_sprite: AnimatedSprite2D
@export var dialogue_action: DialogueAction

var dialogue_res: DialogueResource
var original_sprite_scale: Vector2


func _ready() -> void:
	dialogue_res = dialogue_action.dialogue_res
	original_sprite_scale = animated_sprite.scale

	connect_signals()


## this function is called when a line of dialogue have a mood different than
## the previous storaged mood in [DialogueAction].
func _on_mood_changed(new_mood: String):
	if new_mood in DialogueData.moods:
		change_anim(new_mood)


## tries to match and play animation with the same name as a mood declared
## in [DialogueData.moods].
## NOTE: to add and play a new animation/mood, read [DialogueData]!!!
func change_anim(mood: String):
	if animated_sprite.sprite_frames.has_animation(mood):
		animated_sprite.play(mood)
		bounce_on_it()


func bounce_on_it():
	var tall_scale: Vector2 = Vector2(
		original_sprite_scale.x * (0.9),
		original_sprite_scale.y * (1.1)
		)

	var short_scale: Vector2 = Vector2(
		original_sprite_scale.x * (1.1),
		original_sprite_scale.y * (0.9)
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
	bounce_on_it()


func _on_dialogue_ended():
	pass


func connect_signals():
	dialogue_action.mood_changed.connect(_on_mood_changed)
	dialogue_action.ray_entered.connect(_on_ray_enter)
	dialogue_action.ray_exited.connect(_on_ray_exit)
	dialogue_action.dialogue_started.connect(_on_dialogue_started)
	dialogue_action.dialogue_ended.connect(_on_dialogue_ended)
