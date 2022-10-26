extends Node3D

class_name PumpkinPatch

var multicolor_pumpkin: PackedScene = preload('res://Assets/Scenes/Wackables/WackableObjects/multicolor_lantern.tscn')

@onready var _small_patch: Node3D = $Small
@onready var _large_patch: Node3D = $Large
@onready var _small_patch_collider: StaticBody3D = $BodySmall
@onready var _large_patch_collider: StaticBody3D = $BodyLarge
@onready var _grow_animator: AnimationPlayer = $GrowAnimator

var _has_grown: bool = false
var _has_wacked: bool = false

func _ready() -> void:
	_has_grown = false
	_has_wacked = false
	_set_large_patch(false)
	_set_small_patch(true)

func _set_small_patch(value: bool) -> void:
	_small_patch_collider.set_collision_layer_value(1, value)
	_small_patch.visible = value

func _set_large_patch(value: bool) -> void:
	_large_patch_collider.set_collision_layer_value(1, value)
	_large_patch.visible = value

func _show_carved_patch() -> void:
	_set_large_patch(false)
	_set_small_patch(false)
	$Highlight.queue_free()
	_grow_animator.stop()
	_grow_animator.queue_free()
	_small_patch.queue_free()
	_large_patch.queue_free()
	_large_patch_collider.queue_free()
	_small_patch_collider.queue_free()
	var new_pumpkin := multicolor_pumpkin.instantiate()
	add_child(new_pumpkin)

func spawn_small_pumpkin() -> void:
	_set_large_patch(false)
	_set_small_patch(true)
	_small_patch.global_position = Player.get_player_pos()
	_small_patch.scale = Vector3.ZERO
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_small_patch, "position", Vector3.ZERO, 0.15)
	tween.tween_property(_small_patch, "scale", Vector3.ONE, 0.1)
	tween.tween_callback(func(): _grow_animator.current_animation = "grow")

func _spawn_large_pumpkin() -> void:
	_has_grown = true
	_grow_animator.stop()
	_set_large_patch(true)
	_large_patch.scale = Vector3.ZERO
	var tween: Tween = create_tween()
	tween.tween_property(_large_patch, "scale", Vector3.ONE, 0.15)
	tween.tween_callback(func(): _set_small_patch(false))

func _on_grow_timer_timeout() -> void:
	_spawn_large_pumpkin()

func _on_wack_area_area_entered(area: Area3D) -> void:
	if area.is_in_group('Wacking') and _has_grown and not _has_wacked:
		_has_wacked = true
		_show_carved_patch()
