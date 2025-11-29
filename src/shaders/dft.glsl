#[compute]
#version 450

// #extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_include : require

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer Samples {
  uint samples_start;
  float samples_data[];
};

layout(set = 0, binding = 1, std430) writeonly buffer DFT { vec2 dft[]; };

#include "constants.gdshaderinc"

float get_sample(int index) {
  return samples_data[(index + samples_start) % SAMPLE_COUNT];
}

const float a = 10.0;

float get_window(float x) {
  if (x < -1.0 || x > 1.0) {
    return 0.0;
  }
  return exp(a * sqrt(max(0.0, 1.0 - x * x))) * exp(-a);
}

void main() {
  uint bin = gl_GlobalInvocationID.x;
  vec2 amplitude = vec2(0.0);

  float frequency = LOWEST_FREQUENCY * exp2(bin / EXP_BINS);

  float sample_period = SAMPLE_RATE / frequency;
  float phase_delta = 6.283185307179586 / sample_period;

  int window_size = int(min(8.0 * sample_period, SAMPLE_COUNT_F));
  int window_start = int(floor((SAMPLE_COUNT_F - float(window_size)) * 0.5));
  int window_end = int(ceil((SAMPLE_COUNT_F + float(window_size)) * 0.5));

  float cur_phase = phase_delta * float(window_start);
  float total_window = 0.0;

  for (int sample_index = window_start; sample_index < window_end; sample_index++) {
    float window = get_window((sample_index * 2.0 - SAMPLE_COUNT_F) / window_size);
    amplitude += vec2(cos(cur_phase), sin(cur_phase)) * get_sample(sample_index) * window;
    total_window += window;
    cur_phase += phase_delta;
  }

  dft[bin] = amplitude / total_window;
}
