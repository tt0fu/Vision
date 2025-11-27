shader_type canvas_item;
#include "oklab.gdshaderinc"

const uint SAMPLE_COUNT = 4096u;
const uint BIN_COUNT = 512u;

uniform float scale_x = 1.0;

uniform uint samples_start;
uniform float samples_data[SAMPLE_COUNT];

uniform vec2 dft[BIN_COUNT];
uniform float period = 100.0;
uniform float focus = 0.5;
uniform float center_sample = 2048.0;

float get_raw_sample(int sample_index) {
	if (sample_index < 0) {
		sample_index += int(period * ceil(float(-sample_index) / period));
	}
	if (sample_index >= int(SAMPLE_COUNT)) {
		sample_index -= int(period * ceil(float(sample_index - int(SAMPLE_COUNT) + 1) / period));
	}
	return samples_data[(uint(sample_index) + samples_start) % SAMPLE_COUNT];
}

float get_sample(float sample_index) {
	return mix(
		get_raw_sample(int(floor(sample_index))), 
		get_raw_sample(int(ceil(sample_index))), 
		fract(sample_index)
	);
}


void fragment() {
	vec2 uv = (0.5 - UV) * vec2(scale_x, 1.0);
	float sample_index = UV.x * float(SAMPLE_COUNT);
	sample_index += center_sample - float(SAMPLE_COUNT) * focus;
	float sample = get_sample(sample_index);
	
	//float debug_center = step(abs(sample_index - center_sample), 10);
	//float debug_period = step(abs(sample_index - (center_sample - period / 2.0)), 10) + 
	                     //step(abs(sample_index - (center_sample + period / 2.0)), 10);
	float wave = step(abs(uv.y - sample * 0.45), 0.05);
	//vec2 bin = dft[int(UV.x * float(BIN_COUNT))];
	//float spectrogram = step(abs(1.0 - UV.y - length(bin)), 0.01);
	
	vec3 col = wave * vec3(1.0);// + debug_center * vec3(1.0, 0.0, 0.0) + 
	//debug_period * vec3(0.0, 1.0, 0.0) + spectrogram * vec3(0.0, 0.0, 1.0);

	COLOR = vec4(col, 1.0);
}
