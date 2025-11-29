#ifndef CONSTANTS
#include "constants.gdshaderinc"
#endif

#ifndef DFT
#define DFT
float freq_to_bin(float frequency) {
	return clamp(EXP_BINS * log2(frequency / LOWEST_FREQUENCY), 0.0, BIN_COUNT_F);
}

float bin_to_freq(float bin) {
	return LOWEST_FREQUENCY * exp2(bin / EXP_BINS);
}
#endif