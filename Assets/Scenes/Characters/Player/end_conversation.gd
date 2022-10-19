extends Node

class_name EndConversation

@export var speaker_name: String = "name"
@export var dialog: Array[String] = []

func start() -> void:
	EventSystem.start_dialog.emit(speaker_name, dialog, _callback, 0.1)

func _callback() -> void:
	pass
