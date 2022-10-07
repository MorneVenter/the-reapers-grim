extends Node

var _camera: Camera3D

func register(object: Camera3D) -> void:
	_camera = object

func get_camera() -> Camera3D:
	assert(_camera != null, "No camera object was registered to the Camera singleton.")
	return _camera

func get_position(position: Vector3) -> Vector2:
	return get_camera().unproject_position(position)
