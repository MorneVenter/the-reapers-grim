extends Camera3D

@export_node_path(CharacterBody3D, RigidDynamicBody3D)
var target_node: NodePath
@export
var follow_speed: float = 3.0
@export
var peek_angle: float = 0.0

var target: Node3D
var position_offset: Vector3 = Vector3.ZERO
var origin_rotation: Vector3

func _ready() -> void:
	origin_rotation = rotation
	_check_if_target_node_exists()
	_set_camera_offset()
	position = _get_targeted_position()

func _physics_process(delta):
	_handlePeek()
	_check_if_target_node_exists()
	global_position = global_position.lerp(_get_targeted_position(), follow_speed * delta)

func _set_camera_offset() -> void:
	position_offset = global_position - target.global_position

func _get_targeted_position() -> Vector3:
	_check_if_target_node_exists()
	var global_target_position: Vector3 = target.global_position
	return global_target_position + position_offset

func _check_if_target_node_exists() -> void:
	if target_node == null or target == null:
		target = get_node(target_node)
		assert(target_node != null and target != null, "\"follow_camera\" could not find the node to follow. Insure that it has been asigned on the camera.")

func _handlePeek() -> void:
	var peek_input: Vector2 = get_player_peek_direction()
	var target_rotation = peek_input * deg_to_rad(peek_angle) * -1
	rotation = rotation.lerp(Vector3(target_rotation.y, target_rotation.x, 0) + origin_rotation, 0.1)

func get_player_peek_direction() -> Vector2:
	var player_key_input = Input.get_vector("player_peek_left", "player_peek_right", "player_peek_up", "player_peek_down").normalized()
	if Input.is_action_pressed("right_click"):
		var viewport = get_viewport()
		var mouse_position: Vector2 = viewport.get_mouse_position()
		var screen_size: Vector2 = viewport.get_visible_rect().size
		var mouse_vector: Vector2 = mouse_position / screen_size
		var scale_vector_coord := func(coord: float) -> float: return (coord * 2.0) - 1.0
		var scaled_mouse_vector: Vector2 = Vector2(scale_vector_coord.call(mouse_vector.x), scale_vector_coord.call(mouse_vector.y))
		player_key_input = scaled_mouse_vector * -1.0
	return player_key_input
