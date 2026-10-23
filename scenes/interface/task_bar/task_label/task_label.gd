class_name TaskLabel
extends Control

const TASK_PAPER_ANIM_1: Texture2D = preload("uid://ben7jtp1hle12")
const TASK_PAPER_ANIM_2: Texture2D = preload("uid://cavcipndvmfi")
const TASK_PAPER_ANIM_3: Texture2D = preload("uid://cyddeq2wa0gvu")

@export var paper_sprite_2d: Sprite2D
@export var text_mask: Control
@export var rich_text_label: RichTextLabel
@export var strikethrough_mask: Control

@onready var pivot: Control = $Pivot
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_open: bool = false

var hidden_pos_x: float = 170.0
var closed_pos_x: float = 0.0
var open_pos_x: float = -470.0

var strikethrough_size_init: Vector2 = Vector2(40, 40)
var strikethrough_size_finish: Vector2 = Vector2(660, 40)

var final_size_y: float = 105.0

var read_pause_duration: float = 4.0
var grow_duration: float = 0.2

var slide_duration: float = 0.3
var roll_overlap: float = 0.1

var tween: Tween


func _ready() -> void:
	hide()
	animation_player.play("roll")
	show()
	pivot.position.x = hidden_pos_x
	strikethrough_mask.size = strikethrough_size_init
	strikethrough_mask.hide()

	var t: Tween = _new_tween()
	t.set_ease(Tween.EASE_IN)
	t.tween_property(self, "custom_minimum_size:y", final_size_y, grow_duration)


func change_text(new_text: String) -> void:
	rich_text_label.text = "• %s" % new_text


func change_paper_spr(idx: int) -> void:
	var new_texture: Texture2D = TASK_PAPER_ANIM_1

	match idx:
		0: new_texture = TASK_PAPER_ANIM_1
		1: new_texture = TASK_PAPER_ANIM_2
		2: new_texture = TASK_PAPER_ANIM_3

	paper_sprite_2d.texture = new_texture


func give_anim() -> void:
	if tween != null and tween.is_running():
		await tween.finished

	await open_anim()
	await get_tree().create_timer(read_pause_duration).timeout
	await close_anim()


func complete_anim() -> void:
	await open_anim()
	strikethrough_mask.show()

	var t: Tween = _new_tween()
	t.tween_property(strikethrough_mask, "size", strikethrough_size_finish, 1.0)
	await t.finished

	await get_tree().create_timer(read_pause_duration / 2.0).timeout

	await close_anim()
	await _tween_pivot_x(hidden_pos_x, 0.2)

	t = _new_tween()
	t.set_ease(Tween.EASE_IN)
	t.tween_property(self, "custom_minimum_size:y", 0.0, grow_duration)
	await t.finished

	queue_free()



func open_anim() -> void:
	var t: Tween = _start_pivot_tween(open_pos_x, slide_duration, Tween.EASE_IN)
	await get_tree().create_timer(maxf(slide_duration - roll_overlap, 0.0)).timeout

	animation_player.play_backwards("roll")
	await animation_player.animation_finished

	if t.is_running():
		await t.finished

	is_open = true


func close_anim() -> void:
	var t: Tween = _start_pivot_tween(closed_pos_x, slide_duration, Tween.EASE_IN)
	await get_tree().create_timer(maxf(slide_duration - roll_overlap +0.1, 0.0)).timeout

	animation_player.play("roll")
	await animation_player.animation_finished

	if t.is_running():
		await t.finished

	is_open = false


func _tween_pivot_x(target_x: float, duration: float, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> void:
	var t: Tween = _start_pivot_tween(target_x, duration, ease_type)
	await t.finished


func _start_pivot_tween(target_x: float, duration: float, ease_type: Tween.EaseType = Tween.EASE_IN_OUT) -> Tween:
	var t: Tween = _new_tween()
	t.set_ease(ease_type)
	t.tween_property(pivot, "position:x", target_x, duration)
	return t




func _new_tween() -> Tween:
	if tween != null and tween.is_valid():
		tween.kill()
	tween = create_tween()
	return tween
