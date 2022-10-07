extends Node

var _player: CharacterBody3D

func register(object: CharacterBody3D) -> void:
	_player = object

func get_player() -> CharacterBody3D:
	assert(_player != null, "No player object was registered to the Player singleton.")
	return _player


