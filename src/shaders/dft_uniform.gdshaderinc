#include "constants.gdshaderinc"

#ifndef DFT_UNIFORM
#define DFT_UNIFORM
uniform vec2 dft[BIN_COUNT];
float get_bin(float bin) {
	bin = clamp(bin, 0.0, BIN_COUNT_F - 1.0);
	return mix(
		length(dft[int(floor(bin))]), 
		length(dft[int(ceil(bin))]), 
		fract(bin));
}
#endif