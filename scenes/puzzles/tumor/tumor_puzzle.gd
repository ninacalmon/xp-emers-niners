class_name TumorPuzzle
extends Puzzle


const PEREBA_1: Texture2D = preload("uid://dcbrqhkqrlvnu")
const PEREBA_2: Texture2D = preload("uid://j1rawwwgam1s")
const PEREBA_3: Texture2D = preload("uid://ds2xfcm6x00j0")
const PEREBA_4: Texture2D = preload("uid://x5lwi40vqhk3")
const PEREBA_5: Texture2D = preload("uid://cmpste7ys0wo8")

const WANTED_COUNT: int = 3

@export var time_limit: float = 15.0
@export var submit_button: Button
@export var time_label: Label
@export var wanted_displays: Array[TextureRect] = []

# Keyed by tumor id now, so wanted/selected can be compared by name.
var tumor_options: Dictionary[StringName, Dictionary] = {
	&"pereba_1": {"tex_imagination": PEREBA_1, "tex_tumor": PEREBA_1},
	&"pereba_2": {"tex_imagination": PEREBA_2, "tex_tumor": PEREBA_2},
	&"pereba_3": {"tex_imagination": PEREBA_3, "tex_tumor": PEREBA_3},
	&"pereba_4": {"tex_imagination": PEREBA_4, "tex_tumor": PEREBA_4},
	&"pereba_5": {"tex_imagination": PEREBA_5, "tex_tumor": PEREBA_5},
}

var tumors: Array[TumorButton] = []
var wanted_tumors: Array[StringName] = []
var selected_tumors: Array[TumorButton] = []

var timer: Timer = Timer.new()
var is_running: bool = false

@onready var tumors_control: Control = $MarginContainer/TumorsControl


func _ready() -> void:
	for child: Node in tumors_control.get_children():
		var t: TumorButton = child as TumorButton
		if t == null:
			continue
		tumors.append(t)
		t.toggled.connect(_on_tumor_toggled.bind(t))

	timer.one_shot = true
	timer.timeout.connect(_on_time_up)
	add_child(timer)

	if submit_button != null:
		submit_button.pressed.connect(_on_submit_pressed)

	set_process(false)

	start()


func _process(_delta: float) -> void:
	if time_label != null:
		time_label.text = "%.1f" % timer.time_left


func start() -> void:
	setup_round()
	is_running = true
	timer.start(time_limit)
	set_process(true)
	puzzle_started.emit(true)


func finish(solved: bool) -> void:
	is_running = false
	timer.stop()
	set_process(false)
	for t: TumorButton in tumors:
		t.disabled = true
	puzzle_finished.emit()


func setup_round() -> void:
	selected_tumors.clear()

	var ids: Array[StringName] = []
	ids.assign(tumor_options.keys())
	ids.shuffle()
	wanted_tumors.assign(ids.slice(0, WANTED_COUNT))

	# Guarantee every wanted type exists on the board at least once,
	# then fill the remaining buttons with random types.
	var pool: Array[StringName] = []
	pool.assign(wanted_tumors)
	while pool.size() < tumors.size():
		pool.append(ids.pick_random())
	pool.shuffle()

	for i: int in tumors.size():
		var t: TumorButton = tumors[i]
		var id: StringName = pool[i]
		t.tumor_id = id
		t.texture_normal = tumor_options[id]["tex_tumor"]
		t.disabled = false
		t.set_pressed_no_signal(false)

	for i: int in wanted_displays.size():
		if i < wanted_tumors.size():
			wanted_displays[i].texture = tumor_options[wanted_tumors[i]]["tex_imagination"]

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

	var picked: Array[StringName] = []
	for t: TumorButton in selected_tumors:
		picked.append(t.tumor_id)

	var wanted: Array[StringName] = []
	wanted.assign(wanted_tumors)

	picked.sort()
	wanted.sort()
	return picked == wanted
