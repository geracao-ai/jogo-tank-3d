shader_type spatial;
render_mode cull_disabled, specular_disabled;
// A kit building cut off at a jagged height, for the damaged and destroyed stages: the walls end
// in a burnt edge and the hollow inside shows. Heights are in the model's own units.
// Implements: story-008-estilo-da-cidade. Uses discard, so only ruins pay for it.

uniform sampler2D albedo_tex : source_color, hint_default_white, filter_linear, repeat_disable;
uniform float clip_y = 0.5;
uniform float jag = 0.06;
uniform float burn_band = 0.1;
uniform vec4 burn_color : source_color = vec4(0.2, 0.17, 0.18, 1.0);
uniform vec4 inside_color : source_color = vec4(0.3, 0.26, 0.27, 1.0);
uniform float band_threshold : hint_range(-1.0, 1.0) = 0.15;
uniform float band_softness : hint_range(0.001, 1.0) = 0.25;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float cut = clip_y + jag * (sin(local_pos.x * 17.0) * sin(local_pos.z * 13.0 + local_pos.x * 5.0)
			+ 0.5 * sin(local_pos.x * 41.0 + local_pos.z * 37.0));
	if (local_pos.y > cut) {
		discard;
	}
	vec3 color = texture(albedo_tex, UV).rgb;
	color = mix(color, burn_color.rgb, smoothstep(cut - burn_band, cut, local_pos.y) * 0.85);
	ALBEDO = FRONT_FACING ? color : inside_color.rgb;
	ROUGHNESS = 1.0;
}

void light() {
	float nl = dot(NORMAL, LIGHT);
	float lit = smoothstep(band_threshold, band_threshold + max(band_softness, 0.001), nl);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * lit / PI;
}
