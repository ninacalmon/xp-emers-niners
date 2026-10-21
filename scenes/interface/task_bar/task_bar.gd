class_name TaskBar
extends Control


@onready var task_list: VBoxContainer = $TaskList

@export var auto_close_timer: float = 4.0
@export var task_label_scene: PackedScene

var task_labels: Dictionary[String, TaskLabel] = {}
var selected_label: TaskLabel = null

var is_expanded: bool = false


func _ready() -> void:
	TaskManager.task_given.connect(_on_task_given)
	TaskManager.task_completed.connect(_on_task_completed)

	for task_id in TaskManager.tasks.keys():
		_create_label(task_id, TaskManager.tasks[task_id].get("completed", false))


func _create_label(task_id: String, is_completed: bool) -> TaskLabel:
	var label: TaskLabel = task_label_scene.instantiate()
	task_list.add_child(label) # add first, so TaskLabel's @onready vars exist.

	var text: String = TaskManager.tasks[task_id]["text"]
	label.rich_text_label.text = _format_text(text, is_completed)

	task_labels[task_id] = label
	return label


func _format_text(text: String, completed: bool) -> String:
	if completed:
		return "[s]%s[/s]" % text
	return text


func _on_task_given(task_id: String) -> void:
	var label: TaskLabel = _create_label(task_id, false)
	task_list.move_child(label, 0)

	await label.open()
	await get_tree().create_timer(auto_close_timer).timeout
	await label.close()


func _on_task_completed(task_id: String) -> void:
	if not task_labels.has(task_id):
		return

	var label: TaskLabel = task_labels[task_id]

	if not label.is_open:
		await label.open()

	var text: String = TaskManager.tasks[task_id]["text"]
	label.rich_text_label.text = _format_text(text, true)

	await get_tree().create_timer(auto_close_timer / 2).timeout

	task_list.move_child(label, task_list.get_child_count() - 1)
	await label.close()


func expand_labels():
	for label: TaskLabel in task_list.get_children():
		await label.open()


func contract_labels():
	var children = task_list.get_children()
	children.reverse()

	for label: TaskLabel in children:
		await label.close()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_tasks"):
		if is_expanded:
			is_expanded = false
			contract_labels()
		else:
			is_expanded = true
			expand_labels()
	
