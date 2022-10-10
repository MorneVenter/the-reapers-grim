extends Node

var _current_coins: int = 0

func get_coins() -> int:
	return _current_coins

func deduct(amount: int) -> bool:
	if amount > _current_coins:
		return false
	_current_coins -= amount
	update_ui()
	return true

func add(amount: int) -> void:
	_current_coins += amount
	update_ui()

func update_ui() -> void:
	EventSystem.coins_changed.emit(_current_coins)
