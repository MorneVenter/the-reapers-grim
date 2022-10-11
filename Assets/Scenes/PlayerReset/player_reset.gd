extends Node3D

@export_node_path(Node3D) var respawn_point: NodePath

func _on_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_respawn()

func _respawn() -> void:
	var player: PlayerObject = Player.get_player()
	var pos: Node3D = get_node(respawn_point)
	player.global_position = pos.global_position
