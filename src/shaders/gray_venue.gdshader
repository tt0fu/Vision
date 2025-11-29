shader_type canvas_item;
#include "oklab.gdshaderinc"
#include "dft.gdshaderinc"
#include "dft_uniform.gdshaderinc"
#include "gridnode.gdshaderinc"

uniform float scale_x = 1.0;

uniform float bass = 0.0;
uniform float chrono = 0.0;

float dft_bass(float x) {
	return get_bin(mix(freq_to_bin(30.0), freq_to_bin(100.0), x));
}

vec3 rainbow(float hue) {
	return lch_srgb(vec3(0.8, 0.1, hue));
}

vec3 rainbow_chrono(float x) {
	return rainbow(fract(chrono * 2.0 + x * 0.5));
}

float mover(uint id, uint ch) {
	id %= 8u;
	float x = float(id) / 8.0;
	float mag = dft_bass(x);
	if (ch == 0u || ch == 1u) {
		// Pan, Pan fine
		float pan = 0.5;
		return split_fine(pan, ch);
	}
	if (ch == 2u || ch == 3u) {
		// Tilt, Tilt fine
		float tilt = 0.33 + clamp(mag, 0.0, 0.4);
		return split_fine(tilt, ch - 2u);
	}
	if (ch == 4u) {
		// Zoom
		return mag * 2.0;
	}
	if (ch == 5u) {
		// Dimmer
		return 1.0;
	}
	if (ch == 6u) {
		// Strobe
		return mag * 3.0 - 0.5;
	}
	if (7u <= ch && ch <= 9u) {
		// Red, Green, Blue
		return split_color(rainbow_chrono(x), ch - 7u);
	}
	if (ch == 10u) {
		// GOBO spin speed
		return 0.0;
	}
	if (ch == 11u) {
		// GOBO
		return 0.0;
	}
	if (ch == 12u) {
		// Mover speed
		return 0.5;
	}
	return 0.0;
}

float par_light(uint id, uint ch) {
	id %= 8u;
	float x = float(id) / 8.0;
	float mag = dft_bass(x);
	if (ch == 0u) {
		// dimmer
		return mag * 4.0;
	}
	if (1u <= ch && ch <= 3u) {
		// red, green, blue
		return split_color(rainbow_chrono(x), ch - 1u);
	}
	if (ch == 4u) {
		// strobe
		return mag * 3.0 - 0.5;
	}
	return 0.0;
}

float laser(uint id, uint ch) {
	id %= 8u;
	float x = float(id) / 8.0;
	float mag = dft_bass(x);
	if (ch == 0u) {
		// Pan
		return 1.0 - mag * 1.5;
	}
	if (ch == 1u) {
		// Tilt
		return 0.0;
	}
	if (ch == 2u) {
		// Length
		return 1.0; // - dft;
	}
	if (ch == 3u) {
		// Width
		return mag * 2.0 - 0.6;
	}
	if (ch == 4u) {
		// Flatness
		return 0.0;
	}
	if (ch == 5u) {
		// Beam Count
		return 0.0;
	}
	if (ch == 6u) {
		// Spin Speed
		return 0.0;
	}
	if (7u <= ch && ch <= 9u) {
		// red, green, blue
		 return split_color(rainbow_chrono(x), ch - 7u);
	}
	if (ch == 10u) {
		// Dimmer
		return mag * 4.0 - 0.5;
	}
	if (ch == 11u) {
		// Beam Thickness
		return 0.0;
	}
	if (ch == 12u) {
		// Pan/Tilt Speed
		return 0.0;
	}
	return 0.0;
}



float get_value(uint id){
	if (id < 13u * 16u) {
		return mover(id / 13u, id % 13u);
	}
	if (id < 13u * 16u + 5u * 16u) {
		id -= 13u * 16u;
		return par_light(id / 5u, id % 5u);
	}
	if (id < 13u * 16u + 5u * 16u + 13u * 16u) {
		id -= 13u * 16u + 5u * 16u;
		return laser(id / 13u, id % 13u);
	}
	return 0.0;
}

void fragment() {
	uint id = channel_id(UV);
	float val = get_value(id);
	COLOR = vec4(val, val, val, 1.0);
}
