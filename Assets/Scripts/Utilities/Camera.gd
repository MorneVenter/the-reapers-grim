extends Node

var _camera: Camera3D

func register(object: Camera3D) -> void:
	_camera = object

func _get_camera() -> Camera3D:
	return _camera

func get_position(position: Vector3) -> Vector2:
	var camera: Camera3D = _get_camera()
	if camera == null or not camera.is_visible_in_tree():
		return Vector2(-999, -999)
	return camera.unproject_position(position)
