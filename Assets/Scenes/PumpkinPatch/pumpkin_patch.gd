extends Node3D

class_name PumpkinPatch

@onready var _small_patch: Node3D = $Small
@onready var _large_patch: Node3D = $Large
@onready var _small_patch_collider: StaticBody3D = $BodySmall
@onready var _large_patch_collider: StaticBody3D = $BodyLarge

func _ready() -> void:
	_set_large_patch(false)
	_set_small_patch(true)

func _set_small_patch(value: bool) -> void:
	_small_patch_collider.set_collision_layer_value(1, value)
	_small_patch.visible = value

func _set_large_patch(value: bool) -> void:
	_large_patch_collider.set_collision_layer_value(1, value)
	_large_patch.visible = value

func spawn_small_pumpkin() -> void:
	_set_large_patch(false)
	_set_small_patch(true)
	_small_patch.global_position = Player.get_player_pos()
	_small_patch.scale = Vector3.ZERO
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_small_patch, "position", Vector3.ZERO, 0.15)
	tween.tween_property(_small_patch, "scale", Vector3.ONE, 0.1)
