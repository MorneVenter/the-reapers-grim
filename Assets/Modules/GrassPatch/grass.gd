@tool
extends Node3D

@export_category("Grass Shape")
@export
var radius: float = 4.0
@export_range(0.0, 1.0)
var radius_variance: float = 0.2
@export_range(1, 10000)
var total_grass_blades: int = 256
@export_range(0.0, 10.0)
var grass_blade_height: float = 1.0
@export_range(0.0, 1.0)
var wind_speed: float = 0.1

@export_category("Grass Overrides")
@export
var billboarding: bool = true
@export
var grass_color: GradientTexture1D = null
@export_range(0.0, 10.0)
var wind_strength: float = 1.5

@onready
var grass_mesh: MultiMeshInstance3D = $GrassMultiMesh

func _ready() -> void:
	_generate_grass()

func _generate_grass() -> void:
	randomize()
	var grass_multimesh: MultiMesh = grass_mesh.multimesh
	var grass_shader = grass_mesh.material_override

	grass_multimesh.instance_count = total_grass_blades
	grass_shader.grass_scale = grass_blade_height
	grass_shader.billboard = billboarding
	grass_shader.wind_speed = wind_speed
	grass_shader.wind_strength = wind_strength
	grass_shader.color_ramp = grass_color if grass_color != null else _get_default_grass_color_ramp()

	for instance_index in total_grass_blades:
		var raduis_adjustment: float = 1.0 + randf_range(-radius_variance/2.0, radius_variance/2.0)
		var blade_transform := Transform3D().rotated(Vector3.UP, randf_range(-PI / 2.0, PI / 2.0))
		var x = randf_range(0.0, radius*raduis_adjustment) * cos(instance_index)
		var z = randf_range(0.0, radius*raduis_adjustment) * sin(instance_index)
		blade_transform.origin = Vector3(x, 0, z)
		grass_multimesh.set_instance_transform(instance_index, blade_transform)

func _on_grass_visibility_changed() -> void:
	_generate_grass()

func _get_default_grass_color_ramp() -> GradientTexture1D:
	var default_grass_color: GradientTexture1D = GradientTexture1D.new()
	default_grass_color.gradient = Gradient.new()
	default_grass_color.width = 2048
	default_grass_color.gradient.offsets = [0.085, 0.698, 1.0]
	default_grass_color.gradient.colors = [Color(0.18, 0.58,0.49), Color(0.65, 0.98, 0.43), Color(1,1,1)]
	return default_grass_color
