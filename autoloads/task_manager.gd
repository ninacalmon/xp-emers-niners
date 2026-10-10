extends Node

signal tasks_changed

var tasks: Dictionary = {}


func give_task(id: String, text: String) -> void:
	if tasks.has(id):
		return

	tasks[id] = {
		"text": text,
		"completed": false
	}

	tasks_changed.emit()


func complete_task(id: String) -> void:
	if not tasks.has(id):
		return

	if tasks[id]["completed"]:
		return

	tasks[id]["completed"] = true
	tasks_changed.emit()


func get_tasks() -> Dictionary:
	return tasks
