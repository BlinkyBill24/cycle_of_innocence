shader_type canvas_item;
// Dread post-process: desaturation + breathing vignette + grain, driven by a
// single strength uniform (DreadManager.get_presentation_strength(), already
// scaled by the horror-intensity setting).

uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.02, 0.0, 0.02, 1.0);
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec3 screen = texture(screen_tex, SCREEN_UV).rgb;
	float s = pow(strength, 0.8); // perceptual: low dread already shows a little

	float lum = dot(screen, vec3(0.299, 0.587, 0.114));
	vec3 color = mix(screen, vec3(lum), s * 0.65);

	// breathing vignette: closes in from the edges and slowly pulses
	float breathe = sin(TIME * 1.3) * 0.04 * s;
	float dist = distance(SCREEN_UV, vec2(0.5));
	float vig = smoothstep(0.30 + breathe, 0.85, dist) * s;
	color = mix(color, vignette_color.rgb, clamp(vig, 0.0, 1.0));

	float grain = (rand(SCREEN_UV * 512.0 + vec2(TIME)) - 0.5) * 0.07 * s;
	color += grain;

	COLOR = vec4(color, 1.0);
}
