class_name TaskBar
extends Control


@onready var task_list: VBoxContainer = $TaskList


func _ready() -> void:
	TaskManager.tasks_changed.connect(update_tasks)
	update_tasks()


func update_tasks() -> void:
	for child in task_list.get_children():
		child.queue_free()

	for task in TaskManager.tasks.values():
		var label: Label = Label.new()
		label.text = task["text"]

		if task["completed"]:
			label.modulate = Color.GRAY

		task_list.add_child(label)
