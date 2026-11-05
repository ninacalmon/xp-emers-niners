extends Node

class TaskOwner extends Node:
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
			"medication_for_lucio": {
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
			"find_correct_tumors":{
				"status" : [false, false],
				"txt" : "Ajude hugo a presentar uma 'parte de si mesmo'"
			}
				
		}

	var Hugo: DialogueAction

	var tumor_puzzle = preload("uid://ndxtkrboiso5")
	var wanted_tumors_textures: Array[Texture2D]
	var tumors_solved: bool
	var just_tried_puzzle: bool

	func _get_hugo() -> DialogueAction:
		if is_instance_valid(Hugo):
			return Hugo
		var tree: SceneTree = CharacterData.get_tree()
		Hugo = tree.get_first_node_in_group("hugo") as DialogueAction
		return Hugo


	func _on_tumor_puzzle_finished(solved: bool) -> void:
		print("tumor puzzle finished, solved: ", solved)
		tumors_solved = solved
		if solved:
			CharacterData.Hugo.complete_task("find_correct_tumors")
			print("status after complete_task: ", get_status("find_correct_tumors"))

		var hugo: DialogueAction = _get_hugo()
		if hugo == null:
			push_warning("Hugo not found in group 'hugo'")
			return

		hugo.trigger()


class SansonData extends TaskOwner:
	func _init() -> void:
		tasks = {
			"get_astrolabus": {
				"status": [false, false],
				"txt": "Encontre o Astrólabo perdido de Sanson.",
			},
		}



class ItemData:
	var medication: ItemRes = preload("uid://bkc7dx8duiasn")
	var poison: ItemRes = preload("uid://s1b5gx6p2rg1")
	var flower: ItemRes = preload("uid://dltn5dox1dd8c")
	var astrolabus: = preload("uid://3c0ta31odhc6")



var Julio: JulioData = JulioData.new()
var Lucio: LucioData = LucioData.new()
var Hugo: HugoData = HugoData.new()
var Sanson: SansonData = SansonData.new()
var Item: ItemData = ItemData.new()
