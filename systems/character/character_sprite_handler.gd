class_name CharacterSpriteHandler
extends Node

@export var bounce_duration: float = 0.1
@export var animated_sprite: AnimatedSprite3D
@export var dialogue_action: DialogAction

var dialogue_res: DialogueResource
var original_sprite_scale: Vector3

func _ready() -> void:
	dialogue_res = dialogue_action.dialogue_res

	connect_signals()

	original_sprite_scale = animated_sprite.scale


func _on_mood_changed(new_mood: String):
	print(new_mood)
	if new_mood in DialogueData.moods:
		print("found new mood")
		## change sprite accourndly to mood HERE!
		bounce_on_it()
		pass
			


func bounce_on_it():
	var tall_scale: Vector3 = Vector3(
		original_sprite_scale.x * (0.9),
		original_sprite_scale.y * (1.1),
		original_sprite_scale.z
		)

	var short_scale: Vector3 = Vector3(
		original_sprite_scale.x * (1.1),
		original_sprite_scale.y * (0.9),
		original_sprite_scale.z
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
