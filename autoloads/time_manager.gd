extends Node


signal time_pass(time: Times)


var sun: Sun
#var sun_ui: SunUI
var environment_sky_shader: ShaderMaterial

enum Times {at1200, at1500, at1800, at2100, at2300, at2400}

var current_time: Times = Times.at1200


### TESTING
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("interact"):
		#current_time = wrapi(current_time + 1, 0, Times.size()) as Times
		#set_time(current_time)
###################################


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	await get_tree().process_frame
	_initialize_scene()
	sun = get_tree().get_first_node_in_group("sun")
	if not sun:
		return

	environment_sky_shader = sun.worldEnvironment.environment.sky.sky_material
	set_time(current_time)


func _on_scene_changed() -> void:
	_initialize_scene()


func _initialize_scene() -> void:
	sun = get_tree().get_first_node_in_group("sun")
	if not sun:
		return

	environment_sky_shader = sun.worldEnvironment.environment.sky.sky_material
	set_time(current_time)


func set_time(time: Times):
	setup_sky(time)
	time_pass.emit(time)


func setup_sky(time: Times):
	var sun_current_minutes: float = 120
	var sun_current_scale: float = 10.0
	var sun_current_intensity: float = 5.0
	var sun_current_tint: Color = Color(1.0, 1.0, 0.8, 1.0)

	match time:
		Times.at1200:
			sun_current_minutes = 120
			sun.top_color = Color(0.9, 0.87, 0.72, 1.0)
			sun.bottom_color = Color(0.898, 0.82, 0.62, 1.0)
		Times.at1500:
			sun_current_minutes = 157.5
			sun.top_color = Color(0.9, 0.803, 0.558, 1.0)
			sun.bottom_color = Color(0.9, 0.648, 0.36, 1.0)
		Times.at1800:
			sun_current_minutes = 195
			sun_current_scale = 8
			sun_current_tint = Color(1.0, 0.948, 0.69, 1.0)
			sun.top_color = Color(0.9, 0.717, 0.378, 1.0)
			sun.bottom_color = Color(0.9, 0.558, 0.297, 1.0)
		Times.at2100:
			sun_current_minutes = 232.5
			sun_current_scale = 6.5
			sun_current_tint = Color(1.0, 0.864, 0.52, 1.0)
			sun.top_color = Color(0.9, 0.545, 0.234, 1.0)
			sun.bottom_color = Color(0.9, 0.41, 0.216, 1.0)
		Times.at2300:
			sun_current_minutes = 257
			sun_current_scale = 5
			sun_current_intensity = 20
			sun_current_tint = Color(1.0, 0.74, 0.48, 1.0)
			sun.top_color = Color(0.73, 0.549, 0.343, 1.0)
			sun.bottom_color = Color(0.329, 0.125, 0.043, 1.0)
		Times.at2400:
			sun_current_minutes = 272
			sun_current_scale = 5
			sun_current_intensity = 20
			sun_current_tint = Color(1.0, 0.74, 0.48, 1.0)
			sun.top_color = Color(0.33, 0.124, 0.043, 1.0)
			sun.bottom_color = Color(0.021, 0.16, 0.13, 1.0)

	sun.currentTime = sun_current_minutes
	environment_sky_shader.set_shader_parameter("sun_scale", sun_current_scale)
	environment_sky_shader.set_shader_parameter("sun_intensity", sun_current_intensity)
	environment_sky_shader.set_shader_parameter("sun_tint", sun_current_tint)

	sun.worldEnvironment.environment.sky.sky_material = environment_sky_shader
