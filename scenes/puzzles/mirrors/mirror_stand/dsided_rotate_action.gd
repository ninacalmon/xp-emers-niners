extends ActionTrigger
class_name DoubleSidedRotateAction

const SIDE_A: int = 0
const SIDE_B: int = 1

@export var rich_text_label: RichTextLabel
## The node that rotates (the whole stand, holding both Mirror nodes).
@export var stand: Node3D
@export var rotate_duration: float = 0.15

@export_group("Sides")
## One-sided Mirror nodes placed back to back, one per face of the stand.
@export var mirror_a: Mirror
@export var mirror_b: Mirror
@export var side_a_starts_with_mirror: bool = true
@export var side_b_starts_with_mirror: bool = false
## Visual models for side A. Index 0 = model for a side that STARTS with a mirror,
## index 1, 2, 3 = Mirror A, B, C (same order as accepted_items).
@export var side_a_models: Array[Node3D] = []
## Same layout as side_a_models, for side B.
@export var side_b_models: Array[Node3D] = []

@export_group("Snap Rotation")
## Global rotation (radians, around Y) that solves the puzzle. Step 0 is EXACTLY this value.
@export_range(-260.0, 360.0, 0.00000000000001)
var correct_rotation: float = 0.0
@export_range(2, 36) var step_count: int = 6
## If true, the stand starts at a random step (never the correct one).
@export var randomize_on_start: bool = true

@export_group("Missing Mirror")
## Text shown on the label while looking at a stand that still has an empty side.
@export_multiline var missing_mirror_text: String = "Algo está faltando."
## Items that count as a mirror. The ORDER matters: index 0 -> Mirror A, 1 -> Mirror B, 2 -> Mirror C.
@export var accepted_items: Array[ItemRes] = [preload("uid://cka13d4wlnvfr"), preload("uid://dymw8vckx5n6n"), preload("uid://bsdb5amilihps")]

var is_interacting: bool = false
var is_hovered: bool = false
var rotate_text: String = ""

var _side_has_mirror: Array[bool] = [true, false]
## Which placed mirror (index into accepted_items) each side holds. -1 = the starting mirror.
var _placed_index: Array[int] = [-1, -1]

## Step 0 is the correct rotation. Kept unbounded while tweening so the shortest direction is used.
var target_step: int = 0
var _visual_angle: float = 0.0
var _tween: Tween

@onready var audio_stream_player_rot: AudioStreamPlayer = $AudioStreamPlayerRot
@onready var audio_stream_player_mirror: AudioStreamPlayer = $AudioStreamPlayerMirror

func _ready() -> void:
	super()
	rotate_text = rich_text_label.text
	rich_text_label.hide()

	correct_rotation = get_parent().global_rotation.y

	_side_has_mirror = [side_a_starts_with_mirror, side_b_starts_with_mirror]
	_placed_index = [-1, -1]
	for side: int in [SIDE_A, SIDE_B]:
		_sync_mirror_enabled(side)
		_update_models(side)

	if randomize_on_start:
		randomize_rotation()
	else:
		target_step = _get_current_step_from_stand()
		_apply_angle(_get_angle_for_step(target_step))


func trigger() -> void:
	# Holding a valid mirror item and there is an empty side: place it there.
	if _try_place_mirror():
		return

	# Without any mirror there is nothing worth rotating.
	if not _has_any_mirror():
		return

	is_interacting = true
	_update_label()
	GetEntity.get_player().is_puzzle_locked = true


func ray_enter() -> void:
	is_hovered = true
	_update_label()


func ray_exit() -> void:
	is_hovered = false
	_update_label()


# ---------------------------------------------------------------------------
# Snap rotation
# ---------------------------------------------------------------------------

## True when the stand is exactly on the correct step. Use this instead of comparing float angles.
func is_correct() -> bool:
	return posmod(target_step, step_count) == 0


## Puts the stand on a random step, never the correct one. Call again to reset the puzzle.
func randomize_rotation() -> void:
	target_step = randi_range(1, step_count - 1)
	_apply_angle(_get_angle_for_step(target_step))


func _get_step_angle() -> float:
	return TAU / float(step_count)


func _get_angle_for_step(step: int) -> float:
	return correct_rotation + float(step) * _get_step_angle()


func _get_current_step_from_stand() -> int:
	var diff: float = wrapf(stand.global_rotation.y - correct_rotation, 0.0, TAU)
	return posmod(roundi(diff / _get_step_angle()), step_count)


func _rotate_step(direction: int) -> void:
	target_step += direction

	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_method(_apply_angle, _visual_angle, _get_angle_for_step(target_step), rotate_duration)
	_tween.finished.connect(_on_rotate_finished)

	audio_stream_player_rot.play()


func _on_rotate_finished() -> void:
	target_step = posmod(target_step, step_count)
	_apply_angle(_get_angle_for_step(target_step))


func _apply_angle(angle: float) -> void:
	_visual_angle = angle
	# Setting global_rotation keeps the node's scale. Assumes the stand only rotates around Y.
	stand.global_rotation = Vector3(0.0, angle, 0.0)


# ---------------------------------------------------------------------------
# Sides and mirrors
# ---------------------------------------------------------------------------

func _has_any_mirror() -> bool:
	return _side_has_mirror[SIDE_A] or _side_has_mirror[SIDE_B]


## Returns the first side without a mirror, or -1 if both sides have one.
func _find_empty_side() -> int:
	if not _side_has_mirror[SIDE_A]:
		return SIDE_A
	if not _side_has_mirror[SIDE_B]:
		return SIDE_B
	return -1


## Returns true if a mirror was placed. Never uses an item when both sides already have a mirror.
func _try_place_mirror() -> bool:
	var side: int = _find_empty_side()
	if side == -1:
		return false

	var item: ItemRes = InventoryManager.selected_item
	if item == null:
		return false

	var index: int = accepted_items.find(item)
	if index == -1 or index + 1 >= _get_side_models(side).size():
		return false

	InventoryManager.use_item()
	_side_has_mirror[side] = true
	_placed_index[side] = index
	_sync_mirror_enabled(side)
	_update_models(side)
	_update_label()
	audio_stream_player_mirror.play()
	return true


func _get_side_models(side: int) -> Array[Node3D]:
	if side == SIDE_A:
		return side_a_models
	return side_b_models


func _update_models(side: int) -> void:
	var models: Array[Node3D] = _get_side_models(side)

	var visible_index: int = -1
	if _side_has_mirror[side]:
		visible_index = 0 if _placed_index[side] == -1 else _placed_index[side] + 1

	for i: int in models.size():
		var model: Node3D = models[i]
		if model != null:
			model.visible = i == visible_index


func _sync_mirror_enabled(side: int) -> void:
	var mirror: Mirror = mirror_a if side == SIDE_A else mirror_b
	if mirror != null:
		mirror.enabled = _side_has_mirror[side]


func _update_label() -> void:
	if is_interacting:
		rich_text_label.text = rotate_text
		rich_text_label.show()
	elif is_hovered and _find_empty_side() != -1:
		rich_text_label.text = missing_mirror_text
		rich_text_label.show()
	else:
		rich_text_label.hide()


func _physics_process(_delta: float) -> void:
	if not is_interacting:
		return

	if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("walk_backwards"):
		is_interacting = false
		_update_label()
		GetEntity.get_player().is_puzzle_locked = false
		return

	if Input.is_action_just_pressed("rotate_left"):
		_rotate_step(1)
	elif Input.is_action_just_pressed("rotate_right"):
		_rotate_step(-1)
