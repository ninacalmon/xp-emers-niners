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

	var lucio_received_medicine: bool = false


class LucioData extends TaskOwner:
	pass # no tasks yet


class HugoData extends TaskOwner:
	func _init() -> void:
		tasks = {
			"get_flower": {
				"status": [false, false],
				"txt": "Encontre e traga uma flor para Hugo.",
			},
		}



class SansonData extends TaskOwner:
	func _init() -> void:
		tasks = {
			"get_astrolabus": {
				"status": [false, false],
				"txt": "Encontre o Astrólabo perdido de Sanson.",
			},
		}



class ItemData:
	var remedy: ItemRes = preload("uid://bkc7dx8duiasn")
	var poison: ItemRes = preload("uid://s1b5gx6p2rg1")
	var flower: ItemRes = preload("uid://dltn5dox1dd8c")
	var astrolabus: = preload("uid://3c0ta31odhc6")



var Julio: JulioData = JulioData.new()
var Lucio: LucioData = LucioData.new()
var Hugo: HugoData = HugoData.new()
var Sanson: SansonData = SansonData.new()
var Item: ItemData = ItemData.new()
