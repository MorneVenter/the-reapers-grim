extends Control

@onready var _move: RichTextLabel = $Move
@onready var _jump: RichTextLabel = $Jump
@onready var _scythe: RichTextLabel = $Scythe
@onready var _exit: RichTextLabel = $Exit

func _ready() -> void:
	_set_text()

func _set_text() -> void:
	_move.text = "[%s] move" % _get_move_key()
	_jump.text = "[%s] jump" % _get_jump_key()
	_scythe.text = "[right][%s] scythe [/right]" % _get_scythe_key()
	_exit.text = "[hold %s] exit" % _get_exit_key()

func _get_move_key() -> String:
	return InputManager.MOVE

func _get_jump_key() -> String:
	return InputManager.JUMP

func _get_scythe_key() -> String:
	return InputManager.HIT

func _get_exit_key() -> String:
	return InputManager.EXIT
