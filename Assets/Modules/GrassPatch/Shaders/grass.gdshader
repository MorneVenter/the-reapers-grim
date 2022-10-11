shader_type spatial;
render_mode cull_disabled;

uniform float wind_speed = 0.2;
uniform float wind_strength = 2.0;
uniform float wind_texture_tile_size = 20.0;
uniform float wind_vertical_strength = 0.3;
uniform vec2 wind_horizontal_direction = vec2(1.0,0.5);

uniform sampler2D color_ramp : hint_default_black;
uniform sampler2D wind_noise : hint_default_black;
uniform bool billboard = false;
uniform float grass_scale = 1.0;

void vertex() {
	vec3 world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec2 normalized_wind_direction = normalize(wind_horizontal_direction);
	vec2 world_uv = world_vert.xz / wind_texture_tile_size + normalized_wind_direction * TIME * wind_speed;
	float displacement_affect = (1.0 - UV.y);
	float wind_noise_intensity = (textureLod(wind_noise, world_uv , 0.0).r - 0.5);
	
	vec2 vert_space_horizontal_dir = (inverse(MODEL_MATRIX) * vec4(wind_horizontal_direction, 0.0,0.0)).xy;
	vert_space_horizontal_dir = normalize(vert_space_horizontal_dir);
	
	vec3 bump_wind = vec3(
		wind_noise_intensity * vert_space_horizontal_dir.x,
		1.0 - wind_noise_intensity,
		wind_noise_intensity * vert_space_horizontal_dir.y 
	);
	
	bump_wind = vec3(
		wind_noise_intensity * vert_space_horizontal_dir.y,
		1.0 - wind_noise_intensity,
		wind_noise_intensity * vert_space_horizontal_dir.x 
	);
	normalize(bump_wind);
	bump_wind *= vec3(
		wind_strength,
		wind_vertical_strength,
		wind_strength
	);
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],MODEL_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	}
	vec3 scale_vertex = vec3(grass_scale, grass_scale, grass_scale);
	VERTEX *= scale_vertex;
	VERTEX += (bump_wind * displacement_affect);
}

void fragment() {
	ALBEDO = texture(color_ramp, vec2(1.0 - UV.y, 0)).rgb;
}