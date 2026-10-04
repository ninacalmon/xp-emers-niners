class_name HandsOverlay
extends Control

@onready var r_hands_anim: AnimatedSprite2D = $HandAnimTrack/RHandsAnim
@onready var l_hands_anim: AnimatedSprite2D = $HandAnimTrack/LHandsAnim

@onready var item_spr: Sprite2D = $ItemAnimTrack/ItemSpr

@onready var hand_animation_player: AnimationPlayer = $HandAnimationPlayer
@onready var item_animation_player: AnimationPlayer = $ItemAnimationPlayer

func _ready() -> void:
	play_idle()



func play_item_change(item: ItemRes):
	await play_anim_change()

	if item == null:
		item_spr.texture = null
	else:
		item_spr.texture = item.texture

	await item_animation_player.animation_finished

	play_idle()


func play_idle():
	l_hands_anim.stop()
	r_hands_anim.stop()
	item_animation_player.stop()

	r_hands_anim.play("idle")
	l_hands_anim.play("idle")
	item_animation_player.play("item_idle")


func play_interaction():
	await play_anim_change()

	r_hands_anim.play("interaction")
	await r_hands_anim.animation_finished
	play_idle()


func play_nono():
	await play_anim_change()

	r_hands_anim.play("nono")
	await r_hands_anim.animation_finished
	r_hands_anim.play("idle")







func play_anim_change():
	l_hands_anim.stop()
	r_hands_anim.stop()
	item_animation_player.stop()

	hand_animation_player.play("hand_anim_change")
	item_animation_player.play("item_anim_change")

	await get_tree().create_timer(
	hand_animation_player.current_animation_length / 1.2
		).timeout


func _process(_delta: float) -> void:
	## syncronize hand animations vvv
	if r_hands_anim.animation == "idle" and r_hands_anim.animation == l_hands_anim.animation:
		r_hands_anim.frame = l_hands_anim.frame
		r_hands_anim.frame_progress = l_hands_anim.frame_progress
