class_name TumorPuzzle
extends Puzzle


enum TumorOptions {HEART, STAR, CIRCLE, CLOUD, STARSIX}

const WANTED_COUNT: int = 3

@export var time_limit: float = 15.0
@export var submit_button: Button
@export var time_label: Label


var wanted_tumors: Array[TumorOptions] = []
var selected_tumors: Array[TumorButton] = []

var timer: Timer = Timer.new()
var is_running: bool = false

@onready var tumors_control: Control = $TumorPuzzleControl/MarginContainer/TumorsControl
@onready var tumor_puzzle_control: Control = $TumorPuzzleControl



func _ready() -> void:
	print("puzzle parent: ", get_parent(), " | in tree: ", is_inside_tree())
	tumor_puzzle_control.hide()

	for child: Node in tumors_control.get_children():
		var t: TumorButton = child as TumorButton
		if t == null:
			continue
		t.toggled.connect(_on_tumor_toggled.bind(t))

	timer.one_shot = true
	timer.timeout.connect(_on_time_up)
	add_child(timer)

	if submit_button != null:
		submit_button.pressed.connect(_on_submit_pressed)

	set_process(false)

	#start()


func _process(_delta: float) -> void:
	if time_label != null:
		time_label.text = "%.1f" % timer.time_left


func start() -> void:
	tumor_puzzle_control.show()
	PuzzleManager.puzzle_started.emit(lock_player_movement)
	#setup_round()
	is_running = true
	timer.start(time_limit)
	set_process(true)
	puzzle_started.emit(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func finish(solved: bool) -> void:
	is_running = false
	timer.stop()
	set_process(false)
	puzzle_finished.emit()
	print(solved)


func setup_round() -> void:
	var ids: Array[TumorOptions] = []
	ids.assign(TumorOptions.values())
	ids.shuffle()
	wanted_tumors.assign(ids.slice(0, WANTED_COUNT))

	print("wanted tumors: %s" % ", ".join(_tumor_names(wanted_tumors)))


	if submit_button != null:
		submit_button.disabled = true


func _on_tumor_toggled(toggled_on: bool, tumor: TumorButton) -> void:
	if not is_running:
		return

	if toggled_on:
		if selected_tumors.size() >= WANTED_COUNT:
			# Already holding 3, reject the 4th.
			tumor.set_pressed_no_signal(false)
			return
		selected_tumors.append(tumor)
	else:
		selected_tumors.erase(tumor)

	if submit_button != null:
		submit_button.disabled = selected_tumors.size() != WANTED_COUNT


func _on_submit_pressed() -> void:
	if is_running:
		finish(_evaluate())


func _on_time_up() -> void:
	if is_running:
		finish(_evaluate())


func _evaluate() -> bool:
	if selected_tumors.size() != WANTED_COUNT:
		return false

	var picked: Array[TumorOptions] = []
	for t: TumorButton in selected_tumors:
		picked.append(t.tumor_id)

	var wanted: Array[int] = []
	wanted.assign(wanted_tumors)

	picked.sort()
	wanted.sort()
	return picked == wanted




func _tumor_names(options: Array[TumorOptions]) -> Array[String]:
	var names: Array[String] = []
	for option: TumorOptions in options:
		var option_name: String = TumorOptions.find_key(option)
		names.append(option_name)
	return names


func get_wanted_tumor_textures_path() -> Array[String]:
	if wanted_tumors.size() <= 0:
		return []

	var textures: Array[String] = []
	var tex: String
	for tumor: TumorOptions in wanted_tumors:
		match tumor:
			TumorOptions.HEART:
				tex = "uid://dcbrqhkqrlvnu"
			TumorOptions.STAR:
				tex = "uid://j1rawwwgam1s"
			TumorOptions.CIRCLE:
				tex = "uid://cmpste7ys0wo8"
			TumorOptions.CLOUD:
				tex = "uid://ds2xfcm6x00j0"
			TumorOptions.STARSIX:
				tex = "uid://x5lwi40vqhk3"
		textures.append(tex)

	return textures
