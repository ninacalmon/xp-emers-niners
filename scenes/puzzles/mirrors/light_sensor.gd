class_name LightSensor
extends Area3D
## Counts how many LightBeams are touching this area.
## Beams are raycasts, so a normal Area3D can't detect them: LightBeam checks its own
## segments against sensors and reports here through beam_entered / beam_exited.
## Add one or more CollisionShape3D children to define the sensing volume.

signal beam_count_changed(count: int)
signal lit_changed(is_lit: bool)

@export var abbotts_door: DoubleDoorAction
@export var beams_to_open_door: int = 3

## Collision layer 11. LightBeam.sensor_mask must include this layer.
const COLLISION_LAYER: int = 1 << 10

## How many beams must touch the sensor for it to count as lit.
@export var required_beams: int = 1
## If true, the sensor is lit only when EXACTLY required_beams are touching it.
@export var exact_match: bool = false
@export var hold_time: float = 0.5

var _hold_elapsed: float = 0.0
var is_lit: bool = false

var _beams: Array[LightBeam] = []
var _door_opened: bool = false

func _ready() -> void:
	collision_layer = COLLISION_LAYER
	collision_mask = 0
	monitoring = false
	_update_lit()


func _exit_tree() -> void:
	var beams: Array[LightBeam] = _beams.duplicate()
	for beam: LightBeam in beams:
		beam.forget_sensor(self)
	_beams.clear()


func get_beam_count() -> int:
	return _beams.size()


func get_beams() -> Array[LightBeam]:
	return _beams.duplicate()


func _physics_process(delta: float) -> void:
	if _door_opened:
		return

	if get_beam_count() >= beams_to_open_door:
		_hold_elapsed += delta
		if _hold_elapsed >= hold_time:
			_open_door()
			TimeManager.set_time(TimeManager.Times.at2300)
	else:
		_hold_elapsed = 0.0


func _open_door() -> void:
	_door_opened = true
	if abbotts_door != null:
		abbotts_door.open_door()
	get_tree().call_group(RotateAction.STANDS_GROUP, "lock")


## Called by LightBeam when it stops touching this sensor.
func beam_exited(beam: LightBeam) -> void:
	if not _beams.has(beam):
		return
	_beams.erase(beam)
	beam_count_changed.emit(_beams.size())
	_update_lit()


## Called by LightBeam when one of its segments starts touching this sensor.
func beam_entered(beam: LightBeam) -> void:
	if _beams.has(beam):
		return
	_beams.append(beam)
	beam_count_changed.emit(_beams.size())
	_update_lit()

func _update_lit() -> void:
	var count: int = _beams.size()
	var lit: bool = count == required_beams if exact_match else count >= required_beams
	if lit != is_lit:
		is_lit = lit
		lit_changed.emit(is_lit)
