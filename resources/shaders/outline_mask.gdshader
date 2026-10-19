shader_type spatial;
render_mode blend_mix, unshaded, depth_test_disabled;
stencil_mode write, compare_always, 1;

instance uniform bool outline_enabled = true;

void vertex() {
	if (!outline_enabled) {
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = 0.0;
}