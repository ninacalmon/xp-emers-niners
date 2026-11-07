class_name FocusProgressBar
extends TextureProgressBar


@export var hold_duration: float = 1.0
@export var show_delay: float = 0.1

var hold_time: float = 0.0
var decay_speed: float = 2.0
var slot: InventorySlot

var focus_requested: bool = false

var self_is_focused: bool = false
var focus_mode_on: bool = false

var is_puzzle_locked: bool = false
var is_dialogue_locked: bool = false


func _ready() -> void:
	FocusPlayground.focus.connect(_on_playground_focused)
	slot = get_parent() as InventorySlot
	visible = false
	setup_bar()

	## dialogue n puzzle locking to make inventory static during dialogue! vvv
	DialogueManager.dialogue_started.connect(func(_res): is_dialogue_locked = true)
	DialogueManager.dialogue_ended.connect(func(_res): is_dialogue_locked = false)
	PuzzleManager.puzzle_started.connect(func(lock_player): is_puzzle_locked = lock_player)
	PuzzleManager.puzzle_ended.connect(func(_p): is_puzzle_locked = false)


func _process(delta: float) -> void:
	if not slot.button_slot.button_pressed \
	#or focus_mode_on \
	or not slot.item \
	or is_puzzle_locked \
	or is_dialogue_locked:
		return

	var holding: bool = Input.is_action_pressed("focus_item")

	if holding and not focus_mode_on:
		hold_time += delta
		if hold_time >= show_delay:
			visible = true
	else:
		hold_time -= delta * decay_speed

		if focus_requested and hold_time <= hold_duration * 0.9:
			focus_requested = false

		if hold_time <= 0.01:
			visible = false

	hold_time = clampf(hold_time, 0.0, hold_duration)

	value = hold_time

	if hold_time >= hold_duration and not focus_requested:
		request_focus()


func setup_bar() -> void:
	max_value = hold_duration
	value = hold_time


func request_focus():
	focus_requested = true
	if FocusPlayground.focus_request():
		self_is_focused = true


func _on_playground_focused(_bool: bool):
	focus_mode_on = _bool
