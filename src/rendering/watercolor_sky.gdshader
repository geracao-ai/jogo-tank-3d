shader_type sky;
// Painted watercolour sky: soft wash gradient, blotchy pigment, soft clouds with darker pooled
// edges. Static (no TIME), so the sky never re-renders for animation.
// Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).

uniform vec3 zenith_color : source_color = vec3(0.55, 0.75, 0.93);
uniform vec3 horizon_color : source_color = vec3(0.96, 0.93, 0.86);
uniform vec3 below_color : source_color = vec3(0.80, 0.88, 0.90);
uniform vec3 cloud_color : source_color = vec3(1.0, 0.98, 0.94);
uniform vec3 cloud_edge_color : source_color = vec3(0.78, 0.80, 0.92);
uniform float wash_strength = 0.05;
uniform float cloud_scale = 2.2;
uniform float cloud_coverage = 0.5;
uniform float cloud_softness = 0.18;
uniform float edge_strength = 0.35;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 3; i++) {
		v += a * vnoise(p);
		p *= 2.03;
		a *= 0.5;
	}
	return v / 0.875;
}

void sky() {
	vec3 dir = EYEDIR;
	float h = dir.y;
	vec3 col = mix(horizon_color, zenith_color, smoothstep(0.0, 0.7, h));
	col = mix(col, below_color, 1.0 - smoothstep(-0.25, 0.0, h));
	// Uneven wash: low-frequency pigment pooling.
	vec2 uv = dir.xz / (abs(h) + 0.35);
	col += (fbm(uv * 1.3 + 7.0) - 0.5) * 2.0 * wash_strength;
	// Clouds above the horizon, faded into the haze near it.
	float n = fbm(uv * cloud_scale);
	float body = smoothstep(cloud_coverage, cloud_coverage + cloud_softness, n);
	float rim = smoothstep(cloud_coverage - 0.02, cloud_coverage + 0.05, n)
			* (1.0 - smoothstep(cloud_coverage + 0.05, cloud_coverage + 0.2, n));
	float fade = smoothstep(0.02, 0.25, h);
	col = mix(col, cloud_edge_color, rim * edge_strength * fade);
	col = mix(col, cloud_color, body * fade * 0.92);
	COLOR = col;
}
