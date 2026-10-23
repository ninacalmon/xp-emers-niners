class_name TaskBar
extends Control


@onready var task_list: VBoxContainer = $TaskList

@export var auto_close_timer: float = 4.0
@export var task_label_scene: PackedScene

var task_labels: Dictionary[String, TaskLabel] = {}
var selected_label: TaskLabel = null

var is_expanded: bool = false


func _ready() -> void:
	for c in task_list.get_children():
		c.queue_free()

	TaskManager.task_given.connect(_on_task_given)
	TaskManager.task_completed.connect(_on_task_completed)

	for task_id in TaskManager.tasks.keys():
		_create_label(task_id)


func _create_label(task_id: String) -> TaskLabel:
	var label: TaskLabel = task_label_scene.instantiate()
	task_list.add_child(label) # add first, so TaskLabel's @onready vars exist.

	label.change_text(TaskManager.tasks[task_id]["text"]) 
	label.change_paper_spr(get_child_count() - 1 % 3)

	task_labels[task_id] = label
	return label



func _on_task_given(task_id: String) -> void:
	var label: TaskLabel = _create_label(task_id)
	task_list.move_child(label, 0)

	label.give_anim()



func _on_task_completed(task_id: String) -> void:
	if not task_labels.has(task_id):
		return
#
	var label: TaskLabel = task_labels[task_id]

	label.complete_anim()


func expand_labels():
	for label: TaskLabel in task_list.get_children():
		await label.open_anim()


func contract_labels():
	var children = task_list.get_children()
	children.reverse()

	for label: TaskLabel in children:
		await label.close_anim()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_tasks"):
		if not task_list.get_child(0):
			return
		if is_expanded:
			is_expanded = false
			contract_labels()
		else:
			is_expanded = true
			expand_labels()
	
