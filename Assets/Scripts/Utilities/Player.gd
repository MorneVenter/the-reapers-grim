extends Node

var _player: PlayerObject

func register(object: PlayerObject) -> void:
	_player = object

func get_player() -> PlayerObject:
	assert(_player != null, "No player object was registered to the Player singleton.")
	return _player

func lock_input() -> void:
	get_player().lock_input()

func unlock_input() -> void:
	get_player().unlock_input()
