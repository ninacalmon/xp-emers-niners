extends Node

const PROJECT_DIR: String = "res://screenshots"
const FALLBACK_DIR: String = "user://screenshots"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_P:
			_take_screenshot()

func _take_screenshot() -> void:
	await RenderingServer.frame_post_draw

	var image: Image = get_viewport().get_texture().get_image()

	# res:// is only writable when running from the editor
	var dir_path: String = PROJECT_DIR if OS.has_feature("editor") else FALLBACK_DIR
	DirAccess.make_dir_recursive_absolute(dir_path)

	var timestamp: String = Time.get_datetime_string_from_system().replace(":", "-")
	var path: String = "%s/screenshot_%s.png" % [dir_path, timestamp]

	var err: Error = image.save_png(path)
	if err == OK:
		print("Screenshot saved: ", ProjectSettings.globalize_path(path))
	else:
		push_error("Failed to save screenshot (error code %d)" % err)
