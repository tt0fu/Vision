shader_type canvas_item;
#include "oklab.gdshaderinc"
#include "dft.gdshaderinc"
#include "dft_uniform.gdshaderinc"
uniform float scale_x = 1.0;

void fragment() {
	COLOR = vec4(step(1.0 - UV.y, get_bin(UV.x * BIN_COUNT_F) * 1.5));
}
