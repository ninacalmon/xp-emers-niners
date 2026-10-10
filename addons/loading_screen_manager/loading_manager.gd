extends Node
## Autoloaded by the "Loading Screen Manager" addon as `LoadingManager`.
##
## Call LoadingManager.load_scene("res://your_scene.tscn") from anywhere in
## your project to swap the current scene with a threaded load and an
## animated loading screen in front of it.

## Emitted right before the threaded load begins.
signal loading_started(path: String)
## Emitted after the new scene has been swapped in and the loading screen
## has finished its fade-out.
signal loading_finished(path: String)
## Emitted if ResourceLoader fails to load the requested scene.
signal loading_failed(path: String)

@export var loading_screen_scene: PackedScene = preload("res://addons/loading_screen_manager/loading_screen.tscn")

## Minimum time (seconds) the loading screen stays up, even if the real
## load finishes sooner. Keeps quick loads from flashing on screen.
@export var min_load_time: float = 1.0

var loading_screen: Node = null

var target_scene_path: String = ""
var real_progress: Array = []
var display_progress: float = 0.0
var elapsed_time: float = 0.0
var is_loading: bool = false


## Starts loading `path` and swaps to it once it's ready.
## Safe to call from any script: `LoadingManager.load_scene("res://levels/level_2.tscn")`
func load_scene(path: String) -> void:
	if is_loading:
		push_warning("LoadingManager: load_scene() called while already loading; ignoring.")
		return

	if not ResourceLoader.exists(path):
		push_error("LoadingManager: scene path does not exist: %s" % path)
		loading_failed.emit(path)
		return

	is_loading = true
	target_scene_path = path
	display_progress = 0.0
	elapsed_time = 0.0

	_ensure_loading_screen()
	loading_screen.start_loading()
	loading_started.emit(path)

	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("LoadingManager: failed to request load for %s (error %d)" % [path, err])
		is_loading = false
		target_scene_path = ""
		loading_failed.emit(path)
		return

	set_process(true)


func _ensure_loading_screen() -> void:
	if loading_screen != null and is_instance_valid(loading_screen):
		return
	if loading_screen_scene == null:
		push_error("LoadingManager: no loading_screen_scene assigned.")
		return
	loading_screen = loading_screen_scene.instantiate()
	get_tree().root.add_child(loading_screen)


func _process(delta: float) -> void:
	if target_scene_path == "":
		return

	elapsed_time += delta

	var status := ResourceLoader.load_threaded_get_status(target_scene_path, real_progress)

	if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		printerr("LoadingManager: failed to load scene: ", target_scene_path)
		loading_failed.emit(target_scene_path)
		target_scene_path = ""
		is_loading = false
		set_process(false)
		return

	var actual: float = real_progress[0] if real_progress.size() > 0 else 0.0

	# Force a minimum display duration regardless of how fast the real load is.
	var time_ratio: float = clamp(elapsed_time / min_load_time, 0.0, 1.0)
	var target: float = min(actual, time_ratio)

	# Smooth the displayed progress toward the target instead of jumping.
	display_progress = move_toward(display_progress, target, delta * 1.2)

	var percent := int(display_progress * 100)

	if loading_screen:
		loading_screen.update_progress(percent)

	# Only finish once the resource is fully loaded AND the bar has caught up.
	if status == ResourceLoader.THREAD_LOAD_LOADED and percent >= 100:
		var packed_scene: PackedScene = ResourceLoader.load_threaded_get(target_scene_path)
		var finished_path := target_scene_path

		target_scene_path = ""
		is_loading = false
		set_process(false)

		if packed_scene == null:
			printerr("LoadingManager: failed to load scene: ", finished_path)
			loading_failed.emit(finished_path)
			return

		await get_tree().change_scene_to_packed(packed_scene)

		if loading_screen:
			await loading_screen.finish_loading()

		loading_finished.emit(finished_path)
