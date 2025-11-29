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
	COLOR = vec4(step(1.0 - UV.y, get_bin(UV.x * float(BIN_COUNT)) * 1.5));
}
