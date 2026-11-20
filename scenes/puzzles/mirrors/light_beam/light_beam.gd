class_name LightBeam
extends Node3D

@export var target_marker: Marker3D
@export_flags_3d_physics var hit_mask: int = (1 << 0) | (1 << 9) # World (1) + Mirror (10)
@export var max_bounces: int = 8
@export var max_length: float = 100.0
@export var beam_radius: float = 0.03 # radius of the bright core
@export var flatten_on_reflect: bool = true
@export var color_gradient: Gradient
@export var gradient_length: float = 30.0 # distance travelled for the gradient to complete

@export_group("Look")
@export var glow_scale: float = 5.0 # glow radius = beam_radius * glow_scale
@export var core_intensity: float = 2.0 # above 1.0 feeds the Environment glow (bloom)
@export var glow_intensity: float = 0.7
@export_range(0.0, 1.0) var core_whiten: float = 0.6 # how white-hot the core is
@export_range(0.0, 1.0) var pulse_strength: float = 0.15
@export var pulse_frequency: float = 2.0 # waves per unit of distance
@export var pulse_speed: float = 6.0

const SURFACE_OFFSET: float = 0.001
const FACE_DOT_THRESHOLD: float = 0.99
const CORE_EDGE_POWER: float = 1.0
const GLOW_EDGE_POWER: float = 2.0

var _segments: Array[MeshInstance3D] = []
var _core_cylinder: CylinderMesh
var _glow_cylinder: CylinderMesh

const BEAM_SHADER_CODE: String = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back;

uniform sampler2D gradient_tex : source_color, filter_linear, repeat_disable;
uniform float offset_start = 0.0;
uniform float offset_end = 1.0;
uniform float gradient_length = 30.0;
uniform float intensity = 1.0;
uniform float edge_power : hint_range(0.1, 8.0) = 1.5;
uniform float whiten : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.15;
uniform float pulse_frequency = 2.0;
uniform float pulse_speed = 6.0;

varying float t;

void vertex() {
	t = VERTEX.y + 0.5; // 0 at the segment start, 1 at its end
}

void fragment() {
	float along = mix(offset_start, offset_end, t);
	vec4 col = texture(gradient_tex, vec2(clamp(along, 0.0, 1.0), 0.5));

	// 1.0 at the centre line of the cylinder, 0.0 at its silhouette.
	// Fading the edges hides the hard cylinder outline.
	float rim = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float soft_edge = pow(rim, edge_power);

	// Energy pulse travelling along the beam.
	float pulse = 1.0 + pulse_strength * sin(along * gradient_length * pulse_frequency - TIME * pulse_speed);

	ALBEDO = mix(col.rgb, vec3(1.0), whiten) * intensity;
	ALPHA = clamp(col.a * soft_edge * pulse, 0.0, 1.0);
}
"""

var _shader: Shader
var _gradient_texture: GradientTexture1D

func _ready() -> void:
	_core_cylinder = _make_cylinder(beam_radius)
	_glow_cylinder = _make_cylinder(beam_radius * glow_scale)

	# Fallback if no gradient was assigned in the Inspector
	if color_gradient == null:
		color_gradient = Gradient.new()
		color_gradient.set_color(0, Color(1.0, 0.0, 0.0, 1.0)) # opaque red at the start
		color_gradient.set_color(1, Color(1.0, 1.0, 0.0, 0.0)) # transparent yellow at the end

	_gradient_texture = GradientTexture1D.new()
	_gradient_texture.gradient = color_gradient
	_gradient_texture.width = 256

	_shader = Shader.new()
	_shader.code = BEAM_SHADER_CODE


func _make_cylinder(radius: float) -> CylinderMesh:
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 1.0 # stretched per segment via the basis
	cyl.radial_segments = 16
	cyl.rings = 1
	return cyl


func _make_material(whiten: float, intensity: float, edge_power: float) -> ShaderMaterial:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = _shader
	mat.set_shader_parameter("gradient_tex", _gradient_texture)
	mat.set_shader_parameter("whiten", whiten)
	mat.set_shader_parameter("intensity", intensity)
	mat.set_shader_parameter("edge_power", edge_power)
	return mat


func _physics_process(_delta: float) -> void:
	_update_beam()


func _update_beam() -> void:
	var origin: Vector3 = global_position
	var dir: Vector3 = _get_direction(origin)
	if dir == Vector3.ZERO:
		_hide_all_segments()
		return

	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var points: Array[Vector3] = []
	var remaining: float = max_length
	points.append(origin)

	for _bounce: int in range(max_bounces + 1):
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
				origin, origin + dir * remaining, hit_mask)
		var result: Dictionary = space.intersect_ray(query)

		# Nothing hit: the beam travels to its full length.
		if result.is_empty():
			points.append(origin + dir * remaining)
			break

		var hit_pos: Vector3 = result["position"]
		var hit_normal: Vector3 = result["normal"]
		var collider: Object = result["collider"]
		points.append(hit_pos)

		# Wall or anything that isn't a mirror: the beam stops.
		if not (collider is Mirror):
			break

		# Back side or edge of the mirror: shielded, the beam stops.
		var mirror: Mirror = collider as Mirror
		if hit_normal.dot(mirror.get_reflective_normal()) < FACE_DOT_THRESHOLD:
			break

		# Reflective face: bounce and keep going.
		remaining -= origin.distance_to(hit_pos)
		if remaining <= 0.0:
			break
		dir = dir - 2.0 * dir.dot(hit_normal) * hit_normal
		if flatten_on_reflect:
			dir.y = 0.0
			if dir.length_squared() < 0.0001:
				break # reflection was straight up or down, no horizontal heading
			dir = dir.normalized()
		origin = hit_pos + hit_normal * SURFACE_OFFSET

	_draw_points(points)


func _create_segment() -> MeshInstance3D:
	# Core: thin, bright, white-hot.
	var seg: MeshInstance3D = MeshInstance3D.new()
	seg.mesh = _core_cylinder
	seg.top_level = true
	seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	seg.material_override = _make_material(core_whiten, core_intensity, CORE_EDGE_POWER)

	# Glow: wide, soft, coloured. Child of the core, so it shares its transform.
	var glow: MeshInstance3D = MeshInstance3D.new()
	glow.mesh = _glow_cylinder
	glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	glow.material_override = _make_material(0.0, glow_intensity, GLOW_EDGE_POWER)
	seg.add_child(glow)

	add_child(seg)
	return seg


func _apply_params(mat: ShaderMaterial, start: float, end: float) -> void:
	mat.set_shader_parameter("offset_start", start)
	mat.set_shader_parameter("offset_end", end)
	mat.set_shader_parameter("gradient_length", gradient_length)
	mat.set_shader_parameter("pulse_strength", pulse_strength)
	mat.set_shader_parameter("pulse_frequency", pulse_frequency)
	mat.set_shader_parameter("pulse_speed", pulse_speed)


func _draw_points(points: Array[Vector3]) -> void:
	var needed: int = points.size() - 1
	while _segments.size() < needed:
		_segments.append(_create_segment())

	var gradient_len: float = maxf(gradient_length, 0.001)
	var travelled: float = 0.0

	for i: int in range(_segments.size()):
		var seg: MeshInstance3D = _segments[i]
		if i >= needed:
			seg.visible = false
			continue

		var seg_length: float = points[i].distance_to(points[i + 1])
		_place_segment(seg, points[i], points[i + 1])

		var start: float = travelled / gradient_len
		var end: float = (travelled + seg_length) / gradient_len
		var glow: MeshInstance3D = seg.get_child(0) as MeshInstance3D
		_apply_params(seg.material_override as ShaderMaterial, start, end)
		_apply_params(glow.material_override as ShaderMaterial, start, end)
		travelled += seg_length


func _place_segment(seg: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var dir: Vector3 = to - from
	var length: float = dir.length()
	if length < 0.001:
		seg.visible = false
		return
	seg.visible = true

	var y_axis: Vector3 = dir / length
	var ref: Vector3 = Vector3.UP
	if absf(y_axis.dot(Vector3.UP)) > 0.99:
		ref = Vector3.RIGHT
	var x_axis: Vector3 = ref.cross(y_axis).normalized()
	var z_axis: Vector3 = x_axis.cross(y_axis).normalized()

	seg.global_transform = Transform3D(
		Basis(x_axis, y_axis * length, z_axis),
		(from + to) * 0.5
	)

func _get_direction(origin: Vector3) -> Vector3:
	if target_marker == null:
		return Vector3.ZERO
	var to_target: Vector3 = target_marker.global_position - origin
	if to_target.length_squared() < 0.0001:
		return Vector3.ZERO # marker sits on the beam origin, direction is undefined
	return to_target.normalized()


func _hide_all_segments() -> void:
	for seg: MeshInstance3D in _segments:
		seg.visible = false
