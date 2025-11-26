shader_type canvas_item;
#include "oklab.gdshaderinc"

const uint SAMPLE_COUNT = 16384u;
uniform float samples[SAMPLE_COUNT];
uniform uint start;

void fragment() {
	vec2 normUV = (UV - 0.5) * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	float sample = samples[(uint(UV.x * float(SAMPLE_COUNT)) + start) % SAMPLE_COUNT];

	float val = step(abs(normUV.y - sample), 0.05);
	
	//vec3 col = lch_srgb(vec3(0.8, 0.1, UV.x));
	COLOR = vec4(val, val, val, 1.0);
}
