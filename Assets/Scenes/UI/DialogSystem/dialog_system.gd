extends Control

@onready var _dialog_window: Control = $Window
@onready var _dialog_text: RichTextLabel = $Window/Text
@onready var _name_text: RichTextLabel = $Window/NameText
@onready var _next_audio: AudioStreamPlayer = $NextSound
@onready var _voice_box: VoiceBox = $Voicebox
@onready var _prompt: RichTextLabel = $Window/Prompt/Container/Prompt

const TEXT_TEMPLATE: String = '[center]%s[/center]'

var _is_active: bool = false
var _is_accepting_input: bool = false
var _current_dialog_frames: int = -1
var _dialog_lines: Array[String] = []
var _callback: Callable
var _text_tween: Tween
var _wpm: float = 195.0
var _pitch: float = 0.0
var _name: String = "Name"

var _player_pitch: float = 1.1
var _player_name: String = "Reaper-chan"
var _player_tag: String = "[P]"

var _highlight_tag_open: String = "**"
var _highlight_tag_close: String = "*/*"

var _highlight_open: String = "[color=#84fa58]"
var _highlight_close: String = "[/color]"

func _ready() -> void:
	EventSystem.start_dialog.connect(_show_dialog)
	_stop_dialog()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('player_interact') and _is_accepting_input:
		_show_next_frame()

func _stop_dialog() -> void:
	EventSystem.unzoom_camera.emit()
	_is_accepting_input = false
	_dialog_lines = []
	_current_dialog_frames = -1
	_is_active = false
	var tween: Tween = create_tween()
	_dialog_window.scale = Vector2.ONE
	tween.tween_property(_dialog_window, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(func():
		_dialog_window.visible = false
		if _callback != null:
			_callback.call()
	)

func _show_dialog(actor_name: String, dialog: Array[String], callback: Callable, pitch: float = 1.0) -> void:
	if not _is_active:
		EventSystem.zoom_camera.emit()
		_is_active = true
		_callback = callback
		_dialog_window.visible = true
		_dialog_lines = dialog
		_current_dialog_frames = -1
		_pitch = pitch
		_name = actor_name
		_show_next_frame()
		var tween: Tween = create_tween()
		_dialog_window.scale = Vector2.ZERO
		tween.tween_property(_dialog_window, "scale", Vector2.ONE, 0.12)
		tween.tween_callback(func(): _is_accepting_input = true)
		_prompt.text = TEXT_TEMPLATE % InputManager.INTERACT

func _show_next_frame() -> void:
	if _text_tween != null:
		_text_tween.stop()
		_voice_box.stop_string()
	_next_audio.playing = true
	_current_dialog_frames += 1
	if _current_dialog_frames >= _dialog_lines.size():
		_stop_dialog()
	else:
		_text_tween = create_tween()
		_dialog_text.visible_ratio = 0.0
		var text_to_display: String = _dialog_lines[_current_dialog_frames]
		var is_player_line: bool = text_to_display.contains(_player_tag)
		var voice_pitch: float = _player_pitch if is_player_line else _pitch
		_name_text.text = "[center]%s[/center]" % (_player_name if is_player_line else _name)
		if is_player_line:
			text_to_display = text_to_display.replace(_player_tag, "").strip_edges()
		text_to_display = text_to_display.replace(_highlight_tag_open, _highlight_open)
		text_to_display = text_to_display.replace(_highlight_tag_close, _highlight_close)
		_voice_box.play_string(text_to_display, voice_pitch)
		var total_words: int = text_to_display.count(" ") + 1
		var reading_time: float = total_words / _wpm * 60.0
		_text_tween.set_trans(Tween.TRANS_LINEAR)
		_text_tween.tween_property(_dialog_text, "visible_ratio", 1.0, reading_time)
		_dialog_text.text = TEXT_TEMPLATE % text_to_display

