#[compute]
#version 450

// #extension GL_ARB_separate_shader_objects : enable

layout(local_size_x = 256, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) readonly buffer Samples {
  uint start;
  float data[];
};

layout(set = 0, binding = 1, std430) writeonly buffer DFT { vec2 dft[]; };

const uint SAMPLE_COUNT = 4096;
const uint BIN_COUNT = 512;
const float SAMPLE_RATE = 44100.0;
const float LOWEST_FREQUENCY = SAMPLE_RATE / float(SAMPLE_COUNT);
const float EXP_BINS = floor(BIN_COUNT / log2(SAMPLE_RATE / (2.0 * LOWEST_FREQUENCY)));

float get_sample(uint index) {
  uint wrapped = index + start;
  wrapped = wrapped >= SAMPLE_COUNT ? wrapped - SAMPLE_COUNT : wrapped;
  return data[wrapped];
}

float blackman_nuttall_window(float x) {
  if (x < 0.0 || x > 1.0) {
    return 0.0;
  }
  float arg = 6.283185307179586 * x;
  return 0.3635819 -
         0.4891775 * cos(arg) +
         0.1365995 * cos(2.0 * arg) -
         0.0106411 * cos(3.0 * arg);
}

void main() {
  uint bin = gl_GlobalInvocationID.x;
  vec2 amplitude = vec2(0.0);

  float frequency = LOWEST_FREQUENCY * exp2(bin / EXP_BINS);

  float sample_period = SAMPLE_RATE / frequency;
  float phase_delta = 6.283185307179586 / sample_period;

  uint window_size = uint(min(8.0 * sample_period, float(SAMPLE_COUNT)));

  float cur_phase = 0.0;
  float total_window = 0.0;

  float window_offset = (float(SAMPLE_COUNT) - float(window_size)) * 0.5;

  for (uint sample_index = 0; sample_index < SAMPLE_COUNT; sample_index++) {
    float window = blackman_nuttall_window((sample_index - (SAMPLE_COUNT - window_size) / 2) / window_size);
    amplitude += vec2(cos(cur_phase), sin(cur_phase)) * get_sample(sample_index) * window;
    total_window += window;
    cur_phase += phase_delta;
  }

  dft[bin] = amplitude / total_window;
}
