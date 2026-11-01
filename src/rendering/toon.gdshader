shader_type spatial;
render_mode cull_back, specular_disabled;
// Soft two-tone toon shading for the city, tank, rubble and sea.
// Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
// Lit part = albedo * (ambient + sun); shade part = albedo * ambient only, so the "second
// tone" is set by the environment's ambient colour (a cool tint gives painted shadows).
// No real-time shadows are used. Compatibility-safe: only light() + fragment() + vertex().

uniform vec4 albedo : source_color = vec4(1.0);
// Light/shade boundary on N.L, and how soft that boundary is.
uniform float band_threshold : hint_range(-1.0, 1.0) = 0.15;
uniform float band_softness : hint_range(0.001, 1.0) = 0.25;
// Sea shimmer: 0 disables it (every non-sea surface). Highlights drift slowly over the surface.
uniform float shimmer_strength = 0.0;
uniform vec4 shimmer_color : source_color = vec4(1.0);
uniform float shimmer_scale = 0.35;
uniform float shimmer_speed = 0.4;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = 1.0;
	if (shimmer_strength > 0.0) {
		float a = sin(world_pos.x * shimmer_scale + TIME * shimmer_speed);
		float b = sin(world_pos.z * shimmer_scale * 1.3 - TIME * shimmer_speed * 0.8 + a);
		float glint = smoothstep(0.7, 1.0, a * b);
		ALBEDO = mix(ALBEDO, shimmer_color.rgb, glint * shimmer_strength);
	}
}

void light() {
	float nl = dot(NORMAL, LIGHT);
	float lit = smoothstep(band_threshold, band_threshold + max(band_softness, 0.001), nl);
	// LIGHT_COLOR carries a factor PI (Lambert normalisation); divide it out so light energy reads as set.
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * lit / PI;
}
