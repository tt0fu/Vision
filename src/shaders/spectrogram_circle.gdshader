shader_type canvas_item;
#include "oklab.gdshaderinc"

uniform float scale_x = 1.0;
const uint BIN_COUNT = 512u;
uniform vec2 dft[BIN_COUNT];

float get_bin(float bin) {
	return mix(
		length(dft[int(floor(bin))]), 
		length(dft[int(ceil(bin))]), 
		fract(bin));
}

void fragment() {
	vec2 p = UV - vec2(0.5);
	float r = length(p);
	float theta = abs(atan(p.x, -p.y)) / 3.1415926535;
	float height = max(get_bin(mix(10, 250, theta)) - 0.025, 0.0) * 0.75 + 0.15;
	COLOR = vec4((r > 0.9 * 0.15 && r < height) ? 1.0 : 0.0);
}
