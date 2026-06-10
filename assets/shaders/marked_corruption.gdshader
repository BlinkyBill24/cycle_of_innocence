shader_type canvas_item;

// Vertical-slice stub: Hunger "marked" veins on high ruthlessness (Hardened/Vessel).
uniform float corruption_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec4 mark_color : source_color = vec4(0.55, 0.08, 0.12, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float pulse = 0.5 + 0.5 * sin(TIME * 3.5 + UV.y * 12.0);
	float veins = smoothstep(0.42, 0.58, sin(UV.x * 40.0 + UV.y * 18.0 + TIME * 2.0));
	float marked = corruption_strength * veins * pulse;
	vec3 tinted = mix(base.rgb, mark_color.rgb, marked * 0.35);
	COLOR = vec4(tinted, base.a);
}
