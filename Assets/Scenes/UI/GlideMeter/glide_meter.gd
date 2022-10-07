extends Control

@onready var _meter: Control = $Meter
@onready var _back_wheel: TextureProgressBar = $Meter/BackWheel
@onready var _front_wheel: TextureProgressBar = $Meter/FrontWheel

@export var _player_offset: Vector2 = Vector2(0,0)

var _back_wheel_percentage: float = 0.15
var _wheel_start_tween: Tween
var _wheel_stop_tween: Tween

const NORMAL: Color = Color(1,1,1,1)
const TRANSPARENT: Color = Color(1,1,1,0)

func _ready() -> void:
	EventSystem.show_glide_wheel.connect(start)
	EventSystem.stop_glide_wheel.connect(stop)
	_reset_wheel()

func _process(_delta: float) -> void:
	_meter.position = Camera.get_position(Player.get_player().global_position) + _player_offset

func start(start_percentage: float, duration: float) -> void:
	if _wheel_start_tween != null:
		_wheel_start_tween.stop()
	_wheel_start_tween = create_tween()
	_reset_wheel(start_percentage)
	_front_wheel.radial_fill_degrees -= _front_wheel.radial_fill_degrees * _back_wheel_percentage
	_wheel_start_tween.set_parallel(true)
	_wheel_start_tween.set_trans(Tween.TRANS_LINEAR)
	_wheel_start_tween.tween_property(_front_wheel, "radial_fill_degrees", 0, duration - duration * _back_wheel_percentage)
	_wheel_start_tween.tween_property(_back_wheel, "radial_fill_degrees", 0, duration)
	_wheel_start_tween.tween_property(_meter, "modulate", NORMAL, 0.2)

func stop() -> void:
	if _wheel_stop_tween != null:
		_wheel_stop_tween.stop()
	_wheel_stop_tween = create_tween()
	_wheel_stop_tween.tween_property(_meter, "modulate", TRANSPARENT, 0.2)

func _reset_wheel(fill: float = 1.0) -> void:
	_back_wheel.radial_fill_degrees = fill * 360.0
	_front_wheel.radial_fill_degrees = fill * 360.0
	_meter.modulate = TRANSPARENT
