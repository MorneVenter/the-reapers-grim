extends Control

const _world: PackedScene = preload('res://Assets/Scenes/Levels/World/world.tscn')

@onready var _3d_viewport: SubViewport = $SubViewportContainer/Viewport3D
@onready var _background: TextureRect = $SubViewportContainer/Viewport2D/Background
@onready var _coin_interface: Control = $SubViewportContainer/Viewport2D/CoinInterface

@export var _speaker_name: String = 'Test'
@export var _intro_dialog: Array[String] = ['Test']

func _ready() -> void:
	_coin_interface.visible = false
	_background.visible = true
	var timer: Timer = Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.timeout.connect(func():
		_start_intro()
		timer.queue_free()
		)
	add_child(timer)
	timer.start()

func _start_intro() -> void:
	EventSystem.start_dialog.emit(_speaker_name, _intro_dialog, _load_world, 1.0)

func _load_world() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(func():
		var world = _world.instantiate()
		_3d_viewport.add_child(world)
		_coin_interface.visible = true
		_background.visible = false
		timer.queue_free()
		)
	add_child(timer)
	timer.start()
