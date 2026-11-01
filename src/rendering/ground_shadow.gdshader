shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled;
// Soft painted cast shadow on the ground: the Web target has no real-time shadows.
// Implements: story-008-estilo-da-cidade.

uniform vec4 color : source_color = vec4(0.25, 0.3, 0.5, 0.3);

void fragment() {
	vec2 d = abs(UV - 0.5) * 2.0;
	ALBEDO = color.rgb;
	ALPHA = color.a * (1.0 - smoothstep(0.72, 1.0, max(d.x, d.y)));
}
