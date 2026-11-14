shader_type spatial;
render_mode blend_mix, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;

uniform float normal_depth = 0.25;
uniform float color_compression = 6.0;

uniform vec3 color_one : source_color = vec3(1.0, 0.35, 0.02);
uniform vec3 color_two : source_color = vec3(1.0, 0.65, 0.15);
uniform vec3 color_accent : source_color = vec3(0.1, 0.4, 1.0);
uniform float accent_amount : hint_range(0.0, 1.0) = 0.15; // how much of the cycle is blue

vec3 angle_to_color(float a) {
    if (a < 0.0) return vec3(0.0); // keeps the original behavior (no color for negative angles)

    float h = a * color_compression;
    float t = abs(fract(h * 0.5) * 2.0 - 1.0); // smooth 0..1..0 wave, loops forever

    vec3 orange = mix(color_one, color_two, t);
    float blue_mask = smoothstep(1.0 - accent_amount, 1.0, t); 
    return mix(orange, color_accent, blue_mask);
}

// Function to convert HSV to RGB
// Not my creation, but slightly modified
vec3 hsv2rgb(vec3 hsv) {
    float h = hsv.x * color_compression; // 6.0 transitions the colors faster for us
    float s = hsv.y;
    float v = hsv.z;

    float c = v * s;
    float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
    vec3 rgb = vec3(0.0);

    if (0.0 <= h && h < 1.0) rgb = vec3(c, x, 0.0);
    else if (1.0 <= h && h < 2.0) rgb = vec3(x, c, 0.0);
    else if (2.0 <= h && h < 3.0) rgb = vec3(0.0, c, x);
    else if (3.0 <= h && h < 4.0) rgb = vec3(0.0, x, c);
    else if (4.0 <= h && h < 5.0) rgb = vec3(x, 0.0, c);
    else if (5.0 <= h && h < 6.0) rgb = vec3(c, 0.0, x);

    return rgb + (v - c);
}

/*
Converts a value in range [istart, istop] to a value in range [ostart, ostop].
*/
float range_lerp(float value, float istart, float istop, float ostart, float ostop) {
         return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

void fragment() {
    // Set basic material properties
    ALBEDO = vec3(0.5); // Gray seems to give a nice color mix
	NORMAL_MAP = texture(texture_normal, UV * 2.0).rgb;
	NORMAL_MAP_DEPTH = normal_depth;
    METALLIC = 1.0;
    ROUGHNESS = 0.0;
	EMISSION = vec3(0.125); // Used for that faint glow
}

void light() {
    vec3 normal_dir = normalize(NORMAL); // Direction of surface normal
    vec3 light_dir = normalize(LIGHT); // Direction of light
	vec3 view_dir = normalize(VIEW); // Direction of camera

	vec3 reflection = reflect(light_dir, view_dir); // Get reflected light

    // Calculate the angle between the light direction and the normal
    float angle = dot(reflection, normal_dir);
    vec3 color = angle_to_color(angle); // Use hsv to rgb to turn angle into a color

	// Bound checking
	if (angle > 0.6) {
		angle = range_lerp(angle, 0.6, 0.65, 1.0, 0.0);
		angle = clamp(angle, 0.0, 1.0);
	}

	// Apply that light!
    SPECULAR_LIGHT += color * LIGHT_COLOR *  angle;
	SPECULAR_LIGHT += color * color;
}
