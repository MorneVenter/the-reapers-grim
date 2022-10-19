extends Control

@onready var _text: Control = $Text

func _ready() -> void:
	visible = false
	modulate = Color(1,1,1,0)
	EventSystem.show_credits.connect(show_credits)

func show_credits(callback: Callable) -> void:
	visible = true
	_text.visible = false
	modulate = Color(1,1,1,0)
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 2.5)
	tween.tween_callback(func(): _text.visible = true)

	var timer: Timer = Timer.new()
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(
		func():
			var out_tween: Tween = create_tween()
			out_tween.set_ease(Tween.EASE_IN_OUT)
			out_tween.tween_callback(callback)
			out_tween.tween_property(self, "modulate", Color(1,1,1,0), 1.1)
	)
	add_child(timer)
	timer.start()
