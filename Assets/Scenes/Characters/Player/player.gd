extends CharacterBody3D

class_name PlayerObject

@export_category("Movement")
@export
var JUMP_VELOCITY: float = 9.0
@export
var MOMENTUM_GAIN: float = 0.25
@export
var MAX_SPEED: float = 6.5
@export_range(0.0, 100.0)
var GRAVITY: float = 26.0
@export_range(0.0, 8.0)
var FALL_GRAVITY_MULT: float = 2.5
@export_range(0.0, 8.0)
var FLOAT_GRAVITY_MULT: float = 0.8
@export
var INERTIA: float = 0.9
@export_range(0.1, 1.0)
var AIR_SPEED_MOD: float = 0.65

@export_category("Gliding")
@export
var CAN_GLIDE: bool = true
@export_group("Gliding Physics")
@export_range(0.0, 10.0)
var GLIDE_SPEED_INCREASE: float = 1.0
@export_range(0.0, 0.9)
var GLIDE_GRAVITY_MULT: float = 0.15


var _coyote_timer: Timer
var _current_speed: float = 0.0
var _is_holding_jump: bool = false
var _allow_jumps: bool = true
var _is_in_coyote_time: bool = false
var _is_gliding: bool = false
var _allow_coyote_time: bool = true
var _lock_animation: bool = false
var _animation_to_wait_for: String = ""
var _soul_fragment_level: int = 0
var _glide_timer: Timer
var _is_glide_blocked: bool = false
var _glide_time: float = 1.0
var _is_input_locked: bool = false
var _is_hitting: bool = false

@onready var _player_animator: AnimationPlayer = $Reaper/AnimationPlayer
@onready var _player_mesh: Node3D = $Reaper
@onready var _wings: Node3D = $Reaper/Wings
@onready var _scythe: Node3D = $Reaper/Scythe
@onready var _scythe_animator: AnimationPlayer = $ScytheAnimator
@onready var _hit_area: Area3D = $Reaper/HitArea
@onready var _footstep_audio: AudioStreamPlayer3D = $FootstepSound
@onready var _jump_audio: AudioStreamPlayer3D = $JumpSound
@onready var _wing_audio: AudioStreamPlayer3D = $WingSound

const RUN = "NormalRun"
const FALL = "Falling"
const JUMP = "Jump"
const IDLE = "Idle"
const GLIDE = "Glide"
const SCYTHE_IDLE = "idle"
const SCYTHE_HIT = "hit"

var _is_jump_button_pressed := func() -> bool: return Input.is_action_just_pressed("player_jump")
var _is_jump_button_held := func() -> bool: return Input.is_action_pressed("player_jump")
var _get_player_input_direction := func() -> Vector2: return Input.get_vector("player_move_left", "player_move_right", "player_move_up", "player_move_down").normalized()

func _init() -> void:
	Player.register(self)

func _ready() -> void:
	_coyote_timer = Timer.new()
	add_child(_coyote_timer)
	_coyote_timer.one_shot = true
	_coyote_timer.wait_time = 0.15
	_coyote_timer.timeout.connect(_on_coyote_timer_timeout)

	_set_animation(IDLE)
	_player_animator.connect("animation_finished", _animation_finished)

	_glide_timer = Timer.new()
	add_child(_glide_timer)
	_glide_timer.one_shot = true
	_glide_timer.timeout.connect(_on_glide_timer_timeout)
	_wings.visible = false

	_scythe.visible = true
	_scythe_animator.current_animation = SCYTHE_IDLE
	_hit_area.monitorable = false
	_hit_area.monitoring = false

	_set_footstep_sounds(false)
	_jump_audio.playing = false
	_wing_audio.playing = false

	_init_soul_fragment_level(_soul_fragment_level)

func _physics_process(delta: float) -> void:
	if not _is_input_locked:
		_handle_jump(delta)
		_handle_player_movement()
		_handle_player_hit()
		move_and_slide()
	_handle_animations()
	_handle_footsteps()

func _handle_animations() -> void:
	if velocity.y < 0:
		_lock_animation = false
		if _is_gliding:
			_set_animation(GLIDE)
		else:
			_set_animation(FALL)
	elif  velocity.x != 0 or velocity.z != 0:
		_set_animation(RUN)
	else:
		_set_animation(IDLE)

func _handle_footsteps() -> void:
	_set_footstep_sounds(is_on_floor() and (velocity.x != 0 or velocity.z != 0))

func _set_footstep_sounds(state: bool) -> void:
	if _footstep_audio.playing != state:
		_footstep_audio.playing = state

func _handle_player_hit() -> void:
	if Input.is_action_just_pressed('player_hit') and is_on_floor() and not _is_hitting:
		_hit()

func _hit() -> void:
	_is_hitting = true
	_scythe_animator.current_animation = SCYTHE_HIT

func _handle_player_movement() -> void:
	var input_direction: Vector2 = _get_player_input_direction.call()
	var direction: Vector3= (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	if direction:
		_player_mesh.rotation.y = Angles.lerp_degrees(_player_mesh.rotation.y, atan2(velocity.x, velocity.z), 0.1)
		if _current_speed < MAX_SPEED:
			_current_speed += MOMENTUM_GAIN
		var speed_multiplier: float = GLIDE_SPEED_INCREASE if _is_gliding else 1.0
		if not is_on_floor(): speed_multiplier *= AIR_SPEED_MOD
		velocity.x = direction.x * _current_speed * speed_multiplier
		velocity.z = direction.z * _current_speed * speed_multiplier
	else:
		_current_speed = 0
		velocity.x = move_toward(velocity.x, 0, INERTIA)
		velocity.z = move_toward(velocity.z, 0, INERTIA)

func _check_for_coyote_time() -> void:
	if not _is_in_coyote_time and not is_on_floor() and _allow_coyote_time:
		_is_in_coyote_time = true
		_allow_coyote_time = false
		_coyote_timer.start()
	if is_on_floor():
		_allow_jumps = true

func _handle_jump(delta: float) -> void:
	_check_for_coyote_time()
	if not is_on_floor():
		_apply_gravity(delta)
		if CAN_GLIDE and not _is_in_coyote_time and not _is_hitting:
			_handle_glide_input()
	else:
		_is_glide_blocked = false
		if _is_gliding:
			EventSystem.stop_glide_wheel.emit()
			_hide_wings()
		_is_gliding = false
		_allow_coyote_time = true
	if _is_jump_button_pressed.call() and (_allow_jumps or is_on_floor()) and not _is_gliding and not _is_hitting:
		_jump()
	_check_for_jump_hold()

func _jump() -> void:
	_jump_audio.playing = true
	_set_animation(JUMP, true)
	velocity.y = JUMP_VELOCITY
	_is_holding_jump = true
	_allow_jumps = false

func _glide() -> void:
	_wing_audio.playing = true
	_glide_timer.wait_time = _glide_time
	_glide_timer.start()
	velocity.y = 0.0
	_is_gliding = true
	_is_glide_blocked = true
	EventSystem.show_glide_wheel.emit(_soul_fragment_level / 4.0, _get_glide_time_by_level(_soul_fragment_level))
	_show_wings()

func _handle_glide_input() -> void:
	if _is_jump_button_pressed.call() and not _is_gliding and not _is_glide_blocked:
		_glide()
	elif _is_jump_button_pressed.call() and _is_gliding:
		_is_gliding = false
		EventSystem.stop_glide_wheel.emit()
		_hide_wings()

func _apply_gravity(delta: float) -> void:
	var gravity_multiplier: float = GLIDE_GRAVITY_MULT if _is_gliding else FALL_GRAVITY_MULT if not _is_holding_jump or velocity.y < 0.0 else FLOAT_GRAVITY_MULT
	velocity.y -= GRAVITY * gravity_multiplier * delta

func _check_for_jump_hold() -> void:
	if _is_holding_jump and !_is_jump_button_held.call():
		_is_holding_jump = false

func _on_coyote_timer_timeout() -> void:
	_allow_jumps = is_on_floor()
	_is_in_coyote_time = false

func _set_animation(anim: String, wait_for_finish: bool = false) -> void:
	if not _lock_animation:
		_player_animator.current_animation = anim
		if wait_for_finish:
			_lock_animation = true
			_animation_to_wait_for = anim

func _animation_finished(anim_name: String) -> void:
	if _lock_animation and anim_name == _animation_to_wait_for:
		_lock_animation = false
		_animation_to_wait_for = ""

func _on_glide_timer_timeout() -> void:
	_is_gliding = false
	EventSystem.stop_glide_wheel.emit()
	_hide_wings()

func _set_gliding_level(time: float) -> void:
	if time <= 0:
		CAN_GLIDE = false
	else:
		CAN_GLIDE = true
		_glide_time = time

func _get_glide_time_by_level(level: int) -> float:
	match level:
		0: return 0.0
		1: return 0.5
		2: return 2.3
		3: return 3.7
		4: return 4.0
		_: return 0.0

func _show_wings() -> void:
	_scythe.visible = false
	_wings.visible = true
	_wings.scale = Vector3(0,0,0)
	var tween: Tween = create_tween()
	tween.tween_property(_wings, "scale", Vector3(1.5, 1.5, 1.5), 0.2)

func _hide_wings() -> void:
	_scythe.visible = true
	_wings.scale = Vector3(1,1,1)
	var tween: Tween = create_tween()
	tween.tween_property(_wings, "scale", Vector3(0,0,0), 0.2)
	tween.tween_callback(func(): _wings.visible = false)

func _init_soul_fragment_level(level: int) -> void:
	_soul_fragment_level = level
	_set_gliding_level(_get_glide_time_by_level(_soul_fragment_level))

func increase_soul_fragment_level() -> void:
	if _soul_fragment_level < 4:
		_init_soul_fragment_level(_soul_fragment_level + 1)

func lock_input() -> void:
	_is_input_locked = true

func unlock_input() -> void:
	_is_input_locked = false

func _on_scythe_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == SCYTHE_HIT:
		_scythe_animator.current_animation = SCYTHE_IDLE
		_is_hitting = false
