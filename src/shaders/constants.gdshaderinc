#ifndef CONSTANTS
#define CONSTANTS
const uint SAMPLE_COUNT = 4096u;
const uint BIN_COUNT = 512u;
const float SAMPLE_COUNT_F = float(SAMPLE_COUNT);
const float BIN_COUNT_F = float(BIN_COUNT);
const float SAMPLE_RATE = 44100.0;
const float LOWEST_FREQUENCY = SAMPLE_RATE / SAMPLE_COUNT_F;
const float EXP_BINS = floor(BIN_COUNT_F / log2(SAMPLE_RATE / (2.0 * LOWEST_FREQUENCY)));
#endif