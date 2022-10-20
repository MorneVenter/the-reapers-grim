extends Node3D

const _pumpkin: PackedScene = preload('res://Assets/Scenes/PumpkinPatch/pumpkin_patch.tscn')

func _ready() -> void:
	EventSystem.spawn_pumpkin.connect(_spawn)

func _spawn(new_position: Vector3) -> void:
	var new_pumpkin: PumpkinPatch = _pumpkin.instantiate()
	add_child(new_pumpkin)
	new_pumpkin.global_position = new_position
	new_pumpkin.spawn_small_pumpkin()
