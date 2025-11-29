shader_type canvas_item;
#include "oklab.gdshaderinc"
#include "noise.gdshaderinc"

uniform float line_width = 50.0;

const uint SAMPLE_COUNT = 4096u;
const uint BIN_COUNT = 512u;

uniform float scale_x = 1.0;

uniform uint samples_start;
uniform float samples_data[SAMPLE_COUNT];

uniform vec2 dft[BIN_COUNT];
uniform float period = 100.0;
uniform float focus = 0.5;
uniform float center_sample = 2048.0;

uniform float bass = 0.0;
uniform float chrono = 0.0;

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


float fade(float dist) {
	float x = clamp(dist, 0, 1);
	return 1.0 - (x * x);
	//return x < 1.0 ? 1.0 : 0.0;
}

float pseudo_cross(vec2 a, vec2 b) {
	return a.x * b.y - b.x * a.y;
}

float point_to_segment(vec2 a, vec2 b, vec2 p) {
	vec2 pa = a - p;
	vec2 pb = b - p;
	vec2 ab = b - a;
	if (dot(ab, -pa) < 0.0 || dot(-ab, -pb) < 0.0) {
		return min(length(pa), length(pb));
	}
	if (length(ab) < 1e-12) {
		return length(pa);
	}
	return abs(pseudo_cross(pa, pb)) / length(ab);
}

vec2 sample_point(float sample_index) {
	return vec2(sample_index / float(SAMPLE_COUNT) * scale_x, 
	            get_sample(sample_index) * 0.5 + 0.5); 
}

float wave_distance(float sample_index, float sample_height) {
	vec2 target = vec2(sample_index / float(SAMPLE_COUNT) * scale_x, sample_height);
	float start_index = floor(sample_index - line_width);
	float end_index = ceil(sample_index + line_width);
	float mn = 100000.0;
	vec2 prev = sample_point(start_index);
	for (float index = start_index + 1.0; index <= end_index; index++) {
		vec2 cur = sample_point(index);
		mn = min(mn, point_to_segment(prev, cur, target));
		prev = cur;
	}
	return mn;
}


void fragment() {
	float sample_index = UV.x * float(SAMPLE_COUNT);
	float dist = wave_distance(UV.x * float(SAMPLE_COUNT) + center_sample - float(SAMPLE_COUNT) * focus, 1.0 - UV.y);
	float val = fade(dist * float(SAMPLE_COUNT) / line_width);
	//float val = step(abs(1.0 - UV.y - bass), 0.001);
	vec3 col = lch_srgb(vec3(0.8, 0.1, fract(pattern(UV * 2.0, chrono) + chrono * 2.0)));
	//COLOR = vec4(lch_srgb(vec3(0.7, 0.1, pattern(UV * 2.0, chrono))), 1.0);
	COLOR = vec4(col * val, 1.0);
}
