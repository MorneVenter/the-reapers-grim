extends AudioStreamPlayer
class_name VoiceBox

signal finished_phrase()

const PITCH_MULTIPLIER_RANGE := 0.3
const INFLECTION_SHIFT := 0.4

@export_range(0.0, 1.5) var pitch: float = 1.0

const sounds = {
	'a': preload('res://ExternalAssets/Media/VoiceBox/Sounds/a.wav'),
	'b': preload('res://ExternalAssets/Media/VoiceBox/Sounds/b.wav'),
	'c': preload('res://ExternalAssets/Media/VoiceBox/Sounds/c.wav'),
	'd': preload('res://ExternalAssets/Media/VoiceBox/Sounds/d.wav'),
	'e': preload('res://ExternalAssets/Media/VoiceBox/Sounds/e.wav'),
	'f': preload('res://ExternalAssets/Media/VoiceBox/Sounds/f.wav'),
	'g': preload('res://ExternalAssets/Media/VoiceBox/Sounds/g.wav'),
	'h': preload('res://ExternalAssets/Media/VoiceBox/Sounds/h.wav'),
	'i': preload('res://ExternalAssets/Media/VoiceBox/Sounds/i.wav'),
	'j': preload('res://ExternalAssets/Media/VoiceBox/Sounds/j.wav'),
	'k': preload('res://ExternalAssets/Media/VoiceBox/Sounds/k.wav'),
	'l': preload('res://ExternalAssets/Media/VoiceBox/Sounds/l.wav'),
	'm': preload('res://ExternalAssets/Media/VoiceBox/Sounds/m.wav'),
	'n': preload('res://ExternalAssets/Media/VoiceBox/Sounds/n.wav'),
	'o': preload('res://ExternalAssets/Media/VoiceBox/Sounds/o.wav'),
	'p': preload('res://ExternalAssets/Media/VoiceBox/Sounds/p.wav'),
	'q': preload('res://ExternalAssets/Media/VoiceBox/Sounds/q.wav'),
	'r': preload('res://ExternalAssets/Media/VoiceBox/Sounds/r.wav'),
	's': preload('res://ExternalAssets/Media/VoiceBox/Sounds/s.wav'),
	't': preload('res://ExternalAssets/Media/VoiceBox/Sounds/t.wav'),
	'u': preload('res://ExternalAssets/Media/VoiceBox/Sounds/u.wav'),
	'v': preload('res://ExternalAssets/Media/VoiceBox/Sounds/v.wav'),
	'w': preload('res://ExternalAssets/Media/VoiceBox/Sounds/w.wav'),
	'x': preload('res://ExternalAssets/Media/VoiceBox/Sounds/x.wav'),
	'y': preload('res://ExternalAssets/Media/VoiceBox/Sounds/y.wav'),
	'z': preload('res://ExternalAssets/Media/VoiceBox/Sounds/z.wav'),
	'th': preload('res://ExternalAssets/Media/VoiceBox/Sounds/th.wav'),
	'sh': preload('res://ExternalAssets/Media/VoiceBox/Sounds/sh.wav'),
	' ': preload('res://ExternalAssets/Media/VoiceBox/Sounds/blank.wav'),
	'.': preload('res://ExternalAssets/Media/VoiceBox/Sounds/longblank.wav')
}

var remaining_sounds := []
var _pitch_effect: AudioEffectPitchShift

func _ready() -> void:
	_pitch_effect = AudioServer.get_bus_effect(1, 0)

func play_string(in_string: String):
	_parse_input_string(in_string)
	_play_next_sound()

func stop_string() -> void:
	remaining_sounds = []
	stop()

func _play_next_sound():
	if len(remaining_sounds) == 0:
		emit_signal("finished_phrase")
		return
	var next_symbol = remaining_sounds.pop_front()
	# Skip to next sound if no sound exists for text
	if next_symbol.sound == '':
		_play_next_sound()
		return
	var sound: AudioStream = sounds[next_symbol.sound]
	# Add some randomness to pitch plus optional inflection for end word in questions
	_pitch_effect.pitch_scale = pitch + (PITCH_MULTIPLIER_RANGE * randf()) + (INFLECTION_SHIFT if next_symbol.inflective else 0.0)
	stream = sound
	play()

func _parse_input_string(in_string: String):
	for word in in_string.split(' '):
		_parse_word(word)
		_add_symbol(' ', ' ', false)

func _parse_word(word: String):
	var skip_char := false
	var is_inflective := word[-1] == '?'
	for i in range(len(word)):
		if skip_char:
			skip_char = false
			continue
		# If not the last letter, check if next letter makes a two letter substring, e.g. 'th'
		if i < len(word) - 1:
			var two_character_substring = word.substr(i, i+2)
			if two_character_substring.to_lower() in sounds.keys():
				_add_symbol(two_character_substring.to_lower(), two_character_substring, is_inflective)
				skip_char = true
				continue
		# Otherwise check if single character has matching sound, otherwise add a blank character
		if word[i].to_lower() in sounds.keys():
			_add_symbol(word[i].to_lower(), word[i], is_inflective)
		else:
			_add_symbol('', word[i], false)


func _add_symbol(sound: String, characters: String, inflective: bool):
	remaining_sounds.append({
		'sound': sound,
		'characters': characters,
		'inflective': inflective
	})

func _on_ac_voicebox_finished() -> void:
	_play_next_sound()
