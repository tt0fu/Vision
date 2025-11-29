#ifndef GRIDNODE
#define GRIDNODE
const ivec2 RESOLUTION = ivec2(120, 13);

float split_fine(float value, uint channel) {
	return channel == 0u ? value : fract(value * 256.0);
}

float split_color(vec3 color, uint channel) {
	return channel == 0u ? color.r : channel == 1u ? color.g : color.b;
}

uint channel_id(vec2 uv) {
	ivec2 coords = ivec2(uv * vec2(RESOLUTION));
    return uint(coords.x * RESOLUTION.y + coords.y);
}
#endif