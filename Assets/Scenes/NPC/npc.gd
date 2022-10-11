extends Node3D

@export var _dialog_lines: Array[String] = []

@onready var _prompt: Sprite3D = $Prompt

const PLAYERGROUP: String = "Player"

var _is_player_in_range: bool = false
var _is_dialog_active: bool = false

func _ready() -> void:
	_set_player_in_range(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('player_interact') and _is_player_in_range and not _is_dialog_active:
		_is_dialog_active = true
		Player.lock_input()
		EventSystem.start_dialog.emit(_dialog_lines, _end_dialog)

func _end_dialog() -> void:
	_is_dialog_active = false
	Player.unlock_input()

func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(true)

func _on_trigger_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(false)

func _set_player_in_range(is_in_range: bool) -> void:
	_is_player_in_range = is_in_range
	_prompt.visible = is_in_range
	if is_in_range:
		EventSystem.show_prompt.emit(InputManager.INTERACT)
	else:
		EventSystem.hide_prompt.emit()
