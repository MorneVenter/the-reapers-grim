extends Control

@onready var dialog_window: Control = $Window
@onready var dialog_text: RichTextLabel = $Window/Text

const TEXT_TEMPLATE: String = '[center]%s[/center]'

var _is_active: bool = false
var _is_accepting_input: bool = false
var _current_dialog_frames: int = -1
var _dialog_lines: Array[String] = []
var _callback: Callable

func _ready() -> void:
	EventSystem.start_dialog.connect(_show_dialog)
	_stop_dialog()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('player_interact') and _is_accepting_input:
		_show_next_frame()

func _stop_dialog() -> void:
	_is_accepting_input = false
	_dialog_lines = []
	_current_dialog_frames = -1
	_is_active = false
	var tween: Tween = create_tween()
	dialog_window.scale = Vector2.ONE
	tween.tween_property(dialog_window, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(func():
		dialog_window.visible = false
		if _callback != null:
			_callback.call()
	)

func _show_dialog(dialog: Array[String], callback: Callable) -> void:
	if not _is_active:
		_is_active = true
		_callback = callback
		dialog_window.visible = true
		_dialog_lines = dialog
		_current_dialog_frames = -1
		_show_next_frame()
		var tween: Tween = create_tween()
		dialog_window.scale = Vector2.ZERO
		tween.tween_property(dialog_window, "scale", Vector2.ONE, 0.12)
		tween.tween_callback(func(): _is_accepting_input = true)

func _show_next_frame() -> void:
	_current_dialog_frames += 1
	if _current_dialog_frames >= _dialog_lines.size():
		_stop_dialog()
	else:
		dialog_text.text = TEXT_TEMPLATE % _dialog_lines[_current_dialog_frames]

