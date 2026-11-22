
shader_type particles;

uniform float orbit_speed = 1.5;
uniform float orbit_radius = 0.8;
uniform float vertical_spread = 0.5;
uniform float wobble = 0.15;
uniform float orbit_height = 1.5;

float random(float seed) {
	return fract(sin(seed * 127.1) * 43758.5453);
}

void start() {
	float angle = random(float(INDEX)) * TAU;
	float radius = orbit_radius * (0.7 + random(float(INDEX) + 10.0) * 0.6);

	TRANSFORM[3].xyz = vec3(
		cos(angle) * radius,
		orbit_height + (random(float(INDEX) + 20.0) - 0.5) * vertical_spread,
		sin(angle) * radius
	);

	CUSTOM.x = angle;
	CUSTOM.y = radius;
	CUSTOM.z = random(float(INDEX) + 30.0) * TAU;
}

void process() {
	CUSTOM.x += orbit_speed * DELTA;

	float angle = CUSTOM.x;
	float radius = CUSTOM.y;

	float x = cos(angle) * radius;
	float z = sin(angle) * radius;

	float y = orbit_height + sin(TIME * 3.0 + CUSTOM.z) * wobble;

	TRANSFORM[3].xyz = vec3(x, y, z);
}
