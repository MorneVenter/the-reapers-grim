extends Node3D

@export var _coin_cost: int = 1
@export var _accept_dialog_lines: Array[String] = []
@export var _error_dialog_lines: Array[String] = []

@onready var prompt_animator: AnimationPlayer = $PromptAnimationPlayer
@onready var prompt: Sprite3D = $Prompt

const PLAYERGROUP: String = "Player"

var _is_player_in_range: bool = false
var _is_dialog_active: bool = false
var _has_been_collected: bool = false

var _can_afford: Callable = func(): return _coin_cost <= CurrencyManager.get_coins()

func _ready() -> void:
	_set_player_in_range(false)
	prompt_animator.current_animation = "pulse"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('player_interact') and _is_player_in_range and not _is_dialog_active and not _has_been_collected:
		_is_dialog_active = true
		Player.lock_input()
		if _can_afford.call():
			EventSystem.start_dialog.emit(_render_text_with_coins(_accept_dialog_lines), _end_dialog)
		else:
			EventSystem.start_dialog.emit(_render_text_with_coins(_error_dialog_lines), _end_dialog)

func _end_dialog() -> void:
	_is_dialog_active = false
	Player.unlock_input()
	if _can_afford.call():
		var is_success: bool = CurrencyManager.deduct(_coin_cost)
		if is_success:
			var tween: Tween = create_tween()
			tween.tween_property(self, "scale", Vector3(0.1, 0.1, 0.1), 0.15)
			_has_been_collected = true
			Player.get_player().increase_soul_fragment_level()
			tween.tween_callback(func(): queue_free())

func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(true)

func _on_trigger_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(false)

func _set_player_in_range(is_in_range: bool) -> void:
	_is_player_in_range = is_in_range
	prompt.visible = is_in_range
	if is_in_range:
		EventSystem.show_prompt.emit(InputManager.INTERACT)
	else:
		EventSystem.hide_prompt.emit()

func _render_text_with_coins(raw_text: Array[String]) -> Array[String]:
	var rendered_text: Array[String] = []
	for text_item in raw_text:
		rendered_text.append(text_item.replace("%coin", str(_coin_cost)))
	return rendered_text
