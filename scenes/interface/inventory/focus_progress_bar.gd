class_name FocusProgressBar
extends TextureProgressBar


@export var hold_duration: float = 1.0
@export var show_delay: float = 0.08

var hold_time: float = 0.0
var decay_speed: float = 2.0
var slot: InventorySlot

var focus_requested: bool = false

func _ready() -> void:
	slot = get_parent() as InventorySlot
	visible = false
	setup_bar()


func _process(delta: float) -> void:
	if not slot.button_slot.button_pressed:
		return

	var holding: bool = Input.is_action_pressed("focus_item")

	if holding:
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


func request_focus() -> void:
	focus_requested = true
	print("focus")
