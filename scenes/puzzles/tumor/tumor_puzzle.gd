class_name TumourPuzzle
extends Puzzle

const HEART = preload("uid://bsrxyjuux7g5x")
const PAW = preload("uid://dep06f1jvc4ek")
const BIG_DOT = preload("uid://bt0diuuo08kui")
const DOG = preload("uid://cur58h42bu8fi")
const MOON = preload("uid://gh4egrkhfi7r")
const SMALL_DOT = preload("uid://b6luoud7f5y0s")
const STAR = preload("uid://dtrrf62p0cunh")
const SMILE = preload("uid://b2twdwyfp20ms")
const BELL = preload("uid://ddv3q4pwdllpm")
const TWO_DOTS = preload("uid://be3l4doju425h")
const DINO = preload("uid://dphwh7b52g2g8")
const THING = preload("uid://6wdr1xoytsa4")
const BOW = preload("uid://bv1mtff2cojky")
const MUSH = preload("uid://cbrnb2ih6jyj5")
const BIG_FELLA = preload("uid://digf731le0u8s")
const BUTTERFLY = preload("uid://b6iq8wqp0ssx6")
const SHARK_TOOTH = preload("uid://2furne1lpoqn")
const TEAR = preload("uid://bti8hju575ivv")
const CHICKEN = preload("uid://c4esdxwutir7f")

enum TumorID {
	HEART,
	PAW,
	BIG_DOT,
	DOG,
	MOON,
	SMALL_DOT,
	STAR,
	SMILE,
	BELL,
	TWO_DOTS,
	DINO,
	THING,
	BOW,
	MUSH,
	BIG_FELLA,
	BUTTERFLY,
	SHARK_TOOTH,
	TEAR,
	CHICKEN
}

const tumor_options = {
	TumorID.HEART: HEART,
	TumorID.PAW: PAW,
	TumorID.BIG_DOT: BIG_DOT,
	TumorID.DOG: DOG,
	TumorID.MOON: MOON,
	TumorID.SMALL_DOT: SMALL_DOT,
	TumorID.STAR: STAR,
	TumorID.SMILE: SMILE,
	TumorID.BELL: BELL,
	TumorID.TWO_DOTS: TWO_DOTS,
	TumorID.DINO: DINO,
	TumorID.THING: THING,
	TumorID.BOW: BOW,
	TumorID.MUSH: MUSH,
	TumorID.BIG_FELLA: BIG_FELLA,
	TumorID.BUTTERFLY: BUTTERFLY,
	TumorID.SHARK_TOOTH: SHARK_TOOTH,
	TumorID.TEAR: TEAR,
	TumorID.CHICKEN: CHICKEN
}

const WANTED_COUNT: int = 3

@export var time_limit: float = 15.0

@export var submit_button: Button
@export var time_label: Label


var wanted_tumors: Array[TumorID] = []
var selected_tumors: Array[TumorID] = []

var timer: Timer = Timer.new()
var is_running: bool = false

var last_round_solved: bool = false
var has_finished_round: bool = false

@onready var tumors_control: Control = $TumorPuzzleControl/TumorsControl
@onready var tumor_puzzle_control: Control = $TumorPuzzleControl



func _ready() -> void:
	tumor_puzzle_control.hide()

	for child: Node in tumors_control.get_children():
		var t: TumorButton = child as TumorButton
		if t == null:
			continue
		t.button_pressed = false
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
	if wanted_tumors.is_empty():
		setup_round()

	reset_round()

	PuzzleManager.puzzle_started.emit(lock_player_movement)
	puzzle_started.emit(lock_player_movement)
	tumor_puzzle_control.show()
	is_running = true
	timer.start(time_limit)
	set_process(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func reset_round() -> void:
	selected_tumors.clear()

	for child: Node in tumors_control.get_children():
		var t: TumorButton = child as TumorButton
		if t != null:
			t.set_pressed_no_signal(false)

	if submit_button != null:
		submit_button.disabled = true

	if time_label != null:
		time_label.text = "%.1f" % time_limit


func finish(solved: bool) -> void:
	tumor_puzzle_control.hide()
	is_running = false
	timer.stop()
	set_process(false)

	last_round_solved = solved
	has_finished_round = true

	puzzle_finished.emit(solved)
	PuzzleManager.puzzle_ended.emit(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CharacterData.Hugo.just_tried_puzzle = true

	wanted_tumors.clear()



func was_last_round_solved() -> bool:
	return has_finished_round and last_round_solved



func setup_round() -> void:
	var ids: Array[TumorID] = []
	ids.assign(TumorID.values())
	ids.shuffle()

	wanted_tumors.assign(ids.slice(0, WANTED_COUNT))
	selected_tumors.clear()


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
		selected_tumors.append(tumor.tumor_id)
	else:
		selected_tumors.erase(tumor.tumor_id)

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

	for id: TumorID in selected_tumors:
		print("picked: ", id, " | wanted: ", wanted_tumors)
		if not wanted_tumors.has(id):
			return false
	return true


func get_wanted_tumor_bbcode(img_size: int = 120) -> String:
	if wanted_tumors.is_empty():
		setup_round()

	var parts: Array[String] = []
	for id: TumorID in wanted_tumors:
		var tex: Texture2D = tumor_options[id] as Texture2D
		if tex == null:
			push_error("tumor_options[%s] não é um Texture2D" % TumorID.find_key(id))
			continue
		print("img path: '%s'" % tex.resource_path)
		parts.append("[img=%d]%s[/img]" % [img_size, tex.resource_path])

	var result: String = " ".join(parts)
	return result


func start_and_wait() -> bool:
	await start()
	var solved: bool = await puzzle_finished
	return solved
