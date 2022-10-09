extends Control

@onready var prompt: TextureRect = $Background
@onready var prompt_text: RichTextLabel = $Background/VBoxContainer/Prompt

@export var offset: Vector2 = Vector2(20, 20)

var is_showing: bool = false

func _ready() -> void:
	_hide_prompt()
	EventSystem.show_prompt.connect(_show_prompt)
	EventSystem.hide_prompt.connect(_hide_prompt)

func _process(_delta: float) -> void:
	if is_showing:
		prompt.position = Camera.get_position(Player.get_player().global_position) + offset

func _show_prompt(new_prompt: String) -> void:
	prompt.visible = true
	prompt_text.text = "[center]%s[/center]" % new_prompt
	is_showing = true
	prompt.scale = Vector2.ZERO
	var tween: Tween = create_tween()
	tween.tween_property(prompt, "scale", Vector2(1,1), 0.15)
	tween.set_ease(Tween.EASE_IN_OUT)

func _hide_prompt() -> void:
	if is_inside_tree():
		is_showing = false
		prompt.scale = Vector2(1,1)
		var tween: Tween = self.create_tween()
		tween.tween_property(prompt, "scale", Vector2(0,0), 0.15)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func(): prompt.visible = false)
