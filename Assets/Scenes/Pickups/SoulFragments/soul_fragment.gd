extends Node3D

@onready var prompt_animator: AnimationPlayer = $PromptAnimationPlayer
@onready var prompt: Sprite3D = $Prompt

const PLAYERGROUP: String = "Player"

var is_player_in_range: bool = false

func _ready() -> void:
	_set_player_in_range(false)
	prompt_animator.current_animation = "pulse"


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(true)


func _on_trigger_area_body_exited(body: Node3D) -> void:
	if body.is_in_group(PLAYERGROUP):
		_set_player_in_range(false)

func _set_player_in_range(is_in_range: bool) -> void:
	is_player_in_range = is_in_range
	prompt.visible = is_in_range
	if is_in_range:
		EventSystem.show_prompt.emit("E")
	else:
		EventSystem.hide_prompt.emit()

