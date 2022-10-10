extends Control


@onready var _coin_text: RichTextLabel = $Container/Text
@onready var _container: Control = $Container

const TEXT_TEMPLATE: String = '[center]%d[/center]'

func _ready() -> void:
	_set_coin_text(CurrencyManager.get_coins())
	EventSystem.coins_changed.connect(_set_coin_text)

func _set_coin_text(total: int) -> void:
	_coin_text.text = TEXT_TEMPLATE % total
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_container, "scale", Vector2(1.7, 1.7), 0.05)
	tween.tween_property(_container, "scale", Vector2(1,1), 0.05)



