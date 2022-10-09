/*
	魔法防御シェーダー 4 by あるる（きのもと 結衣）
	Magical Shield Shader 4 by Yui Kinomoto @arlez80

	MIT License
*/

shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec2 speed = vec2( 0.2, 0.2 );
uniform vec4 barrier_color : source_color = vec4( 0.05, 0.8, 1.0, 1.0 );
uniform float barrier_force = 1.0;
uniform float barrier_noise_force = 0.3;
uniform float barrier_fog_noise_force = 0.01;
uniform sampler2D barrier_noise : hint_normal;

void fragment( )
{
	float rim = pow( 1.0 - dot( NORMAL, VIEW ), 4.0 ) * barrier_force;

	vec2 p = texture( barrier_noise, -UV ).xy + TIME * speed;
	float line_noise = clamp( ( sin( texture( barrier_noise, p ).r * 3.1415926535 ) - 0.995 ) * 90.0, 0.0, 1.0 ) * barrier_noise_force - barrier_noise_force * 0.5;
	vec3 line_color = texture( SCREEN_TEXTURE, SCREEN_UV + line_noise ).rgb;
	vec3 fog_color = texture( SCREEN_TEXTURE, SCREEN_UV + texture( barrier_noise, vec2( UV.x * 8.0 - TIME * speed.x, UV.y * 8.0 ) ).r * barrier_fog_noise_force - barrier_fog_noise_force * 0.5 ).rgb;

	ALBEDO = mix( fog_color.rgb, line_color.rgb, ( abs(line_noise) < 0.1 ) ? 1.0 : 0.0 ) + barrier_color.rgb * rim;
	ALPHA = 1.0;
}