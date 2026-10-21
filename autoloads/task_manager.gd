extends Node


var tasks: Dictionary = {}

signal task_given(task_id: String)
signal task_completed(task_id: String)


func give_task(id: String, text: String) -> void:
	if tasks.has(id):
		return

	tasks[id] = {
		"text": text,
		"shown": false,
		"completed": false
	}

	task_given.emit(id)


func complete_task(id: String) -> void:
	if not tasks.has(id):
		return

	if tasks[id]["completed"]:
		return

	tasks[id]["completed"] = true
	task_completed.emit(id)


func get_tasks() -> Dictionary:
	return tasks
