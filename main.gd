extends Control

const _world: PackedScene = preload('res://Assets/Scenes/Levels/World/world.tscn')

@onready var _3d_viewport: SubViewport = $SubViewportContainer/Viewport3D
@onready var _background: TextureRect = $SubViewportContainer/Viewport2D/Background
@onready var _coin_interface: Control = $SubViewportContainer/Viewport2D/CoinInterface
@onready var _made_by: TextureRect = $SubViewportContainer/Viewport2D/MadeBy
@onready var _hints: Control = $SubViewportContainer/Viewport2D/ControlHints

@export_range(0, 2) var _speaker_pitch: float = 1.0
@export var _speaker_name: String = 'Test'
@export var _intro_dialog: Array[String] = ['Test']

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_coin_interface.visible = false
	_background.visible = true
	_made_by.visible = true
	_hints.visible = false
	var timer: Timer = Timer.new()
	timer.wait_time = 4.5
	timer.one_shot = true
	timer.timeout.connect(func():
		_made_by.visible = false
		_start_intro()
		timer.queue_free()
		)
	add_child(timer)
	timer.start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('mute'):
		AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))

func _start_intro() -> void:
	EventSystem.start_dialog.emit(_speaker_name, _intro_dialog, _load_world, _speaker_pitch)

func _load_world() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(func():
		var world = _world.instantiate()
		_hints.visible = true
		_3d_viewport.add_child(world)
		_coin_interface.visible = true
		_background.visible = false
		timer.queue_free()
		)
	add_child(timer)
	timer.start()
