shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

instance uniform bool outline_enabled = true;
instance uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
instance uniform float size : hint_range(1.0, 1.5, 0.01) = 1.03;

void vertex() {
	if (outline_enabled) {
		VERTEX *= size;
	} else {
		// Scales the outline geometry down to 0 to make it invisible
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	if (!outline_enabled) {
		discard;
	}
	ALBEDO = color.rgb;
	ALPHA = color.a;
}