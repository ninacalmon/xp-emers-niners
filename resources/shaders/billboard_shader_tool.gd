@tool
class_name Sprite3dOutlineShader
extends Sprite3D

var _last_material: ShaderMaterial

func _ready() -> void:
	if not texture_changed.is_connected(_update_shader_texture):
		texture_changed.connect(_update_shader_texture)
	set_process(true)
	_update_shader_material()

func _process(_delta: float) -> void:
	if material_override != _last_material:
		_update_shader_material()

func _update_shader_material() -> void:
	_last_material = material_override as ShaderMaterial
	_update_shader_texture()

func _update_shader_texture() -> void:
	var mat: ShaderMaterial = material_override as ShaderMaterial
	if mat != null and texture != null:
		mat.set_shader_parameter("sprite_texture", texture)

func set_line_color(color: Color) -> void:
	set_instance_shader_parameter("line_color", color)

func enable_outline(enable: bool) -> void:
	set_instance_shader_parameter("enable_outline", enable)

func set_glow_size(size: float) -> void:
	set_instance_shader_parameter("glowSize", size)

func get_glow_size() -> float:
	return get_instance_shader_parameter("glowSize") as float

func set_billboard_y_only(enable: bool) -> void:
	set_instance_shader_parameter("billboard_y_only", enable)
