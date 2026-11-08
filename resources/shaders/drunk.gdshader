shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.x += sin(uv.y * 10.0 + TIME * 2.0) * 0.01;
	uv.y += cos(uv.x * 10.0 + TIME * 2.0) * 0.01;
	COLOR = texture(screen_texture, uv);
}