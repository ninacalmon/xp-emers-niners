extends CanvasLayer
## Visual loading screen driven by LoadingManager. Not meant to be used
## standalone — LoadingManager instantiates and drives this scene.

@export var progress_bar: ProgressBar
@export var status_text: Label
@export var percent_text: Label
@export var anim: AnimationPlayer
## Optional: assign a sound to play when loading hits 100%.
@export var done_sound: AudioStreamPlayer

var last_percent := -1


func start_loading() -> void:
	last_percent = -1
	progress_bar.value = 0
	percent_text.text = "0%"
	status_text.text = "Loading..."
	anim.play("fade_in")


func update_progress(value: int) -> void:
	# Only update visuals when the whole percent actually changes.
	if value == last_percent:
		return
	last_percent = value

	progress_bar.value = value
	percent_text.text = str(value) + "%"

	if value < 30:
		status_text.text = "Initializing..."
	elif value < 70:
		status_text.text = "Loading assets..."
	elif value < 100:
		status_text.text = "Finalizing..."
	else:
		status_text.text = "Done!"


func finish_loading() -> void:
	if status_text.text == "Done!" and done_sound:
		await get_tree().create_timer(0.2).timeout
		done_sound.play()

	await get_tree().create_timer(0.5).timeout

	anim.play("fade_out")
	await anim.animation_finished

	queue_free()
