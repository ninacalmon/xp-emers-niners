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
@export var light_beam_left: OmniLight3D
@export var light_beam_center: OmniLight3D
@export var light_beam_right: OmniLight3D
@export var light_fade_in_time: float = 0.6
@export var light_fade_out_time: float = 0.4

## Collision layer 11. LightBeam.sensor_mask must include this layer.
const COLLISION_LAYER: int = 1 << 10

const BEAM_NAME_LEFT: StringName = &"LightBeamL"
const BEAM_NAME_CENTER: StringName = &"LightBeamC"
const BEAM_NAME_RIGHT: StringName = &"LightBeamR"

## How many beams must touch the sensor for it to count as lit.
@export var required_beams: int = 1
## If true, the sensor is lit only when EXACTLY required_beams are touching it.
@export var exact_match: bool = false
@export var hold_time: float = 0.5

var _hold_elapsed: float = 0.0
var is_lit: bool = false

var _beams: Array[LightBeam] = []
var _door_opened: bool = false

## Target energy of each OmniLight3D (read from the editor value at startup).
var _light_target_energy: Dictionary = {}
## Active tween of each OmniLight3D, so a new one can replace the old one.
var _light_tweens: Dictionary = {}


func _ready() -> void:
	collision_layer = COLLISION_LAYER
	collision_mask = 0
	monitoring = false

	for light: OmniLight3D in [light_beam_left, light_beam_center, light_beam_right]:
		if light == null:
			continue
		_light_target_energy[light] = light.light_energy
		light.light_energy = 0.0
		light.visible = false

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
	_set_beam_light(beam, false)
	beam_count_changed.emit(_beams.size())
	_update_lit()


## Called by LightBeam when one of its segments starts touching this sensor.
func beam_entered(beam: LightBeam) -> void:
	if _beams.has(beam):
		return
	_beams.append(beam)
	_set_beam_light(beam, true)
	beam_count_changed.emit(_beams.size())
	_update_lit()


func _get_light_for_beam(beam: LightBeam) -> OmniLight3D:
	match beam.name:
		BEAM_NAME_LEFT:
			return light_beam_left
		BEAM_NAME_CENTER:
			return light_beam_center
		BEAM_NAME_RIGHT:
			return light_beam_right
	return null


func _set_beam_light(beam: LightBeam, turn_on: bool) -> void:
	var light: OmniLight3D = _get_light_for_beam(beam)
	if light == null:
		return

	var old_tween: Tween = _light_tweens.get(light) as Tween
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()

	var tween: Tween = create_tween()
	_light_tweens[light] = tween

	if turn_on:
		light.visible = true
		var target_energy: float = _light_target_energy.get(light, 1.0) as float
		tween.tween_property(light, "light_energy", target_energy, light_fade_in_time)
	else:
		tween.tween_property(light, "light_energy", 0.0, light_fade_out_time)
		tween.tween_callback(func() -> void: light.visible = false)


func _update_lit() -> void:
	var count: int = _beams.size()
	var lit: bool = count == required_beams if exact_match else count
