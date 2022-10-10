extends Node3D

@export var _coin_count: int = 3

@onready var coin: PackedScene = preload('res://Assets/Scenes/Pickups/Coins/coin.tscn')
@onready var _mesh: Node3D = $Mesh
@onready var _respawn_timer: Timer = $RespawnTimer


var _current_coins: int = 0

func _ready() -> void:
	_respawn()

func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.is_in_group('Wacking'):
		_wack()

func _wack() -> void:
	_spawn_coin()
	_mesh.rotation = Vector3.ZERO
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_mesh, "rotation", Vector3(0.0, 0.0, deg_to_rad(30.0)), 0.1)
	tween.tween_property(_mesh, "rotation", Vector3(0.0, 0.0, deg_to_rad(-30.0)), 0.07)
	tween.tween_property(_mesh, "rotation", Vector3.ZERO, 0.035)

func _spawn_coin() -> void:
	if _current_coins >= 1:
		_current_coins -= 1
		var new_coin = coin.instantiate()
		add_child(new_coin)
		new_coin.position.y = 1.0
		var z_range: float = randf_range(2.0, 3.3)
		var x_range: float = randf_range(-1.0, 1.0)
		var new_position: Vector3 = Vector3(x_range, 0.5, z_range)
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(new_coin, "position", new_position, 0.15)
		if _current_coins <= 0:
			_respawn_timer.start()

func _respawn() -> void:
	_current_coins  =_coin_count

func _on_respawn_timer_timeout() -> void:
	_respawn()
