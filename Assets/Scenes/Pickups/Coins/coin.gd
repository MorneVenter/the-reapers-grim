extends Node3D

@export var _respawns: bool = false

@onready var _animator: AnimationPlayer = $AnimationPlayer
@onready var _coin: Node3D = $Coin
@onready var _starting_position: Vector3 = position
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _pickup_audio: AudioStreamPlayer = $PickupSound

const APPEAR_ANIM: String = 'appear'
const IDLE_ANIM: String = 'idle'

var _is_collected: bool = false

func _ready() -> void:
	visible = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == APPEAR_ANIM:
		_animator.current_animation = IDLE_ANIM

func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not _is_collected:
		_is_collected = true
		_pickup_audio.playing = true
		CurrencyManager.add(1)
		_animator.stop()
		_coin.scale = Vector3.ONE
		var tween: Tween = create_tween()
		var new_position: Vector3 = position
		new_position.y += 3.5
		tween.tween_property(self, "position", new_position, 0.2)
		tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.1)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(func():
			if _respawns:
				_reset()
				visible = false
				_respawn_timer.start()
			else:
				queue_free()
		)

func _reset() -> void:
	position = _starting_position
	scale = Vector3.ONE
	_coin.scale = Vector3.ONE
	_animator.current_animation = IDLE_ANIM
	visible = true

func _respawn() -> void:
	_reset()
	_is_collected = false

func _on_respawn_timer_timeout() -> void:
	if _is_collected:
		_respawn()
