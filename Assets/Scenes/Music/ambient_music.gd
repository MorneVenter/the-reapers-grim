extends Node3D


@onready var music_one: AudioStreamPlayer3D = $MusicOne
@onready var music_two: AudioStreamPlayer3D = $MusicTwo

func _ready() -> void:
	_play_random_music()

func _play_random_music() -> void:
	randomize()
	music_one.playing = false
	music_two.playing = false
	var r: float = randf()
	if r >= 0.5:
		music_one.playing = true
	else:
		music_two.playing = true

func _on_music_one_finished() -> void:
	_play_random_music()

func _on_music_two_finished() -> void:
	_play_random_music()
