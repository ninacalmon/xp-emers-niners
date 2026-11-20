extends ActionTrigger
class_name RotateAction

@export var rich_text_label: RichTextLabel
@export var mirror_stand: Mirror
@export var rotate_duration: float = 0.15

@export_group("Snap Rotation")
## Number of snap angles, evenly spaced over 360 degrees. One of them is EXACTLY mirror_stand.correct_rotation.
@export_range(2, 36) var step_count: int = 6
## If true, the stand starts at a random step (never the correct one), so the player has to solve it.
@export var randomize_on_start: bool = true

@export_group("Missing Mirror")
## If false, this stand starts without a mirror: it can't be rotated until a mirror item is placed.
@export var starts_with_mirror: bool = true
## Text shown on the label while looking at a stand that has no mirror.
@export_multiline var missing_mirror_text: String = "Algo está faltando."
## Items that count as a mirror. The ORDER matters: index 0 -> Mirror A, 1 -> Mirror B, 2 -> Mirror C.
@export var accepted_items: Array[ItemRes] = [preload("uid://cka13d4wlnvfr"), preload("uid://dymw8vckx5n6n"), preload("uid://bsdb5amilihps")]

@export_group("Mirror Models (inside MirrorMesh)")
## Model used by stands that start with a mirror.
@export var mirror_start_model: Node3D
@export var mirror_a_model: Node3D
@export var mirror_b_model: Node3D
@export var mirror_c_model: Node3D

@onready var audio_stream_player_rot: AudioStreamPlayer = $AudioStreamPlayerRot
@onready var audio_stream_player_mirror: AudioStreamPlayer = $AudioStreamPlayerMirror

var is_interacting: bool = false
var has_mirror: bool = true
var is_hovered: bool = false
var placed_index: int = -1
var rotate_text: String = ""

## Step 0 is the correct rotation. Kept unbounded while tweening so the shortest direction is always used.
var target_step: int = 0
var _visual_angle: float = 0.0
var _tween: Tween


func _ready() -> void:
	super()
	rotate_text = rich_text_label.text
	rich_text_label.hide()
	has_mirror = starts_with_mirror
	placed_index = -1
	_sync_mirror_enabled()
	_update_models()

	if randomize_on_start:
		randomize_rotation()
	else:
		target_step = _get_current_step_from_stand()
		_apply_angle(_get_angle_for_step(target_step))


func trigger() -> void:
	if not has_mirror:
		_try_place_mirror()
		return

	# Stand already has a mirror: items are never used here, it only enters rotation mode.
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


## Step 0 -> exactly correct_rotation. Other steps are evenly spread around the circle.
func _get_angle_for_step(step: int) -> float:
	return mirror_stand.correct_rotation + float(step) * _get_step_angle()


## Used when not randomizing: finds the closest step to the stand's current rotation.
func _get_current_step_from_stand() -> int:
	var diff: float = wrapf(mirror_stand.global_rotation.y - mirror_stand.correct_rotation, 0.0, TAU)
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
	# Normalize and snap to the exact value (step 0 == exactly correct_rotation).
	target_step = posmod(target_step, step_count)
	_apply_angle(_get_angle_for_step(target_step))


func _apply_angle(angle: float) -> void:
	_visual_angle = angle
	# Setting global_rotation keeps the node's scale. Assumes the stand only rotates around Y.
	mirror_stand.global_rotation = Vector3(0.0, angle, 0.0)


# ---------------------------------------------------------------------------
# Placing a mirror
# ---------------------------------------------------------------------------

func _try_place_mirror() -> void:
	if has_mirror:
		return

	var item: ItemRes = InventoryManager.selected_item
	if item == null:
		return

	var index: int = accepted_items.find(item)
	if index == -1 or index >= _get_placed_models().size():
		InventoryManager.tried_wrong_item()
		return

	InventoryManager.use_item()
	has_mirror = true
	placed_index = index
	_sync_mirror_enabled()
	_update_models()
	_update_label()
	audio_stream_player_mirror.play()


func _get_placed_models() -> Array[Node3D]:
	var models: Array[Node3D] = [mirror_a_model, mirror_b_model, mirror_c_model]
	return models


func _update_models() -> void:
	var placed_models: Array[Node3D] = _get_placed_models()

	if mirror_start_model != null:
		mirror_start_model.visible = has_mirror and placed_index == -1

	for i: int in placed_models.size():
		var model: Node3D = placed_models[i]
		if model != null:
			model.visible = has_mirror and placed_index == i


func _sync_mirror_enabled() -> void:
	var parent_mirror: Mirror = get_parent() as Mirror
	if parent_mirror != null:
		parent_mirror.enabled = has_mirror


func _update_label() -> void:
	if is_interacting:
		rich_text_label.text = rotate_text
		rich_text_label.show()
	elif is_hovered and not has_mirror:
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

	if not has_mirror:
		return

	if Input.is_action_just_pressed("rotate_left"):
		_rotate_step(1)
	elif Input.is_action_just_pressed("rotate_right"):
		_rotate_step(-1)
