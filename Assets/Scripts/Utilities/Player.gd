extends Node

var _player: PlayerObject

func register(object: PlayerObject) -> void:
	_player = object

func get_player() -> PlayerObject:
	assert(_player != null, "No player object was registered to the Player singleton.")
	return _player

func get_player_pos() -> Vector3:
	if _player == null:
		return Vector3(-999, -999, -999)
	return _player.global_position

func lock_input() -> void:
	get_player().lock_input()

func unlock_input() -> void:
	get_player().unlock_input()
