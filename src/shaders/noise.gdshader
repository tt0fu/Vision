shader_type canvas_item;
#include "oklab.gdshaderinc"
#include "noise.gdshaderinc"

uniform float line_width = 50.0;

const uint SAMPLE_COUNT = 4096u;
const uint BIN_COUNT = 512u;

uniform float scale_x = 1.0;

uniform float bass = 0.0;
uniform float chrono = 0.0;

void fragment() {
	vec3 col = lch_srgb(vec3(0.8, 0.1, fract(pattern(UV * vec2(scale_x * 2.0, 2.0), chrono) + chrono * 2.0)));
	COLOR = vec4(col, 1.0);
}
