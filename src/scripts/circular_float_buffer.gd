class_name CircularFloatBuffer

var buffer
var start = 0
var size


func _init(sz: int):
	size = sz;
	var init = [];
	init.resize(size);
	init.fill(0.0);
	buffer = PackedFloat32Array(init);

func append(arr: Array):
	var sz = arr.size();
	for i in range(sz):
		buffer.set((start + i) % size, (arr[i].x + arr[i].y) * 0.5);
	start = (start + sz) % size;

func get_buffer() -> PackedFloat32Array:
	return buffer;

func get_start() -> int:
	return start;
