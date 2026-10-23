extends Node

class TaskOwner:
	## each task is: {"status": [given, completed], "txt": String}
	var tasks: Dictionary = {}

	func give_task(task_id: String) -> void:
		if not tasks.has(task_id):
			push_error("Unknown task: %s" % task_id)
			return
		var task: Dictionary = tasks[task_id]
		task["status"] = [true, false]
		TaskManager.give_task(task_id, task["txt"] as String)

	func complete_task(task_id: String) -> void:
		if not tasks.has(task_id):
			push_error("Unknown task: %s" % task_id)
			return
		var task: Dictionary = tasks[task_id]
		task["status"] = [true, true]
		TaskManager.complete_task(task_id)

	## 0 = not given, 1 = given, 2 = completed
	func get_status(task_id: String) -> int:
		if not tasks.has(task_id):
			push_error("Unknown task: %s" % task_id)
			return 0
		var status: Array = tasks[task_id]["status"] as Array
		if status[1] as bool:
			return 2
		if status[0] as bool:
			return 1
		return 0


class JulioData extends TaskOwner:
	func _init() -> void:
		tasks = {
			"remedy_for_lucio": {
				"status": [false, false],
				"txt": "Leve remédio para Lucio e retorne.",
			},
			"get_poison": {
				"status": [false, false],
				"txt": "Traga veneno para os animais.",
			},
		}

	var remedy_item: ItemRes = preload("uid://bkc7dx8duiasn")
	var lucio_received_medicine: bool = false


class LucioData extends TaskOwner:
	pass # no tasks yet


var Julio: JulioData = JulioData.new()
var Lucio: LucioData = LucioData.new()
