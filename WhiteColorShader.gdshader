shader_type canvas_item;

uniform bool active = false;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	float active_f = float(active);
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	COLOR = white_color * active_f + previous_color * (1.0-active_f);
}