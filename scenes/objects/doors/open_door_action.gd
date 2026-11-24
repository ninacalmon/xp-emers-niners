class_name OpenDoorAction
extends ActionTrigger

@export var open_rotation: int = 95
@export var flip: bool = false
@export var speed: float = 0.4
@export var flipped_area_z: float = 0.77


@export var collision_shape_3d: CollisionShape3D
@export var mesh_instance_3d: Node3D

@onready var interaction_area: InteractionArea = $InteractionArea

@export var locked: bool = false
@export var unlockeable: bool = true
@export var locked_stream_player: AudioStreamPlayer

@export_group("Lockpick")
@export var lockpickable: bool = false
@export var lockpick_item: ItemRes
@export var qte_points_to_open: int = 6
@export var qte_max_misses: int = 3

var is_open: bool = false
var _picking: bool = false

@onready var open_audio_stream_player: AudioStreamPlayer = $OpenAudioStreamPlayer

func _ready() -> void:
	super()

	if flip and collision_shape_3d != null:
		interaction_area.position.z = flipped_area_z



func trigger() -> void:
	if _picking:
		return

	if locked:
		var selected: ItemRes = InventoryManager.selected_item

		if unlockeable and wanted_item != null and selected == wanted_item:
			locked = false
			locked_stream_player.play()
		elif lockpickable and lockpick_item != null and selected == lockpick_item:
			await _try_lockpick()
			if locked:
				return
		else:
			locked_stream_player.play()
			await shake_door()
			return

	if is_open:
		await close_door()
	else:
		await open_door()


func _try_lockpick() -> void:
	var qte: LockpickQTE = get_tree().get_first_node_in_group("lockpick_qte") as LockpickQTE
	var player: Player = get_tree().get_first_node_in_group("player") as Player
	if qte == null or player == null:
		push_warning("OpenDoorAction: LockpickQTE or Player not found in groups")
		return

	_picking = true
	player.is_cutscene_locked = true

	var result: LockpickQTE.Result = await qte.run(qte_points_to_open, qte_max_misses)

	_picking = false

	match result:
		LockpickQTE.Result.SUCCESS:
			player.is_cutscene_locked = false
			locked = false
		LockpickQTE.Result.FAILED:
			player.is_cutscene_locked = false
			InventoryManager.use_item() # the lockpick breaks
			locked_stream_player.play()
			await shake_door()
		LockpickQTE.Result.CANCELLED:
			pass # whoever cancelled it (the prior) owns the player lock now


func relock() -> void:
	if is_open:
		await close_door()
	locked = true


func ray_enter() -> void:
	pass


func ray_exit() -> void:
	pass


func open_door() -> void:
	is_open = true

	collision_shape_3d.disabled = true

	var direction: float = -1.0 if flip else 1.0
	var target_angle: float = deg_to_rad(open_rotation) * direction

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(mesh_instance_3d, "rotation:y", target_angle, speed)
	open_audio_stream_player.play()

	await tween.finished


func close_door() -> void:
	is_open = false

	collision_shape_3d.disabled = true

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(mesh_instance_3d, "rotation:y", deg_to_rad(0), speed)

	await tween.finished

	collision_shape_3d.disabled = false


func shake_door() -> void:
	var original_rotation: float = mesh_instance_3d.rotation.y
	var shake_amount: float = deg_to_rad(3.0)
	var shake_duration: float = 0.06

	var tween: Tween = create_tween()
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation + shake_amount, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation - shake_amount, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation + shake_amount * 0.5, shake_duration)
	tween.tween_property(mesh_instance_3d, "rotation:y", original_rotation, shake_duration)

	await tween.finished
