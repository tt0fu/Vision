extends Node
func create_packed_float32_array(count: int) -> PackedFloat32Array:
	var init = []
	init.resize(count)
	init.fill(0.0)
	return PackedFloat32Array(init)

func create_packed_vector2_array(count: int) -> PackedVector2Array:
	var init = []
	init.resize(count)
	init.fill(Vector2(0.0, 0.0))
	return PackedVector2Array(init)

var capture = AudioServer.get_bus_effect(0, 0)

var device = RenderingServer.create_local_rendering_device()
var dft_file = load("res://shaders/dft.glsl")
var dft_spirv: RDShaderSPIRV = dft_file.get_spirv()
var dft_shader = device.shader_create_from_spirv(dft_spirv)

func create_uniform(buffer: RID, binding: int) -> RDUniform:
	var uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding
	uniform.add_id(buffer)
	return uniform

const SAMPLE_COUNT = 4096
var samples_start = 0
var samples_data = create_packed_float32_array(SAMPLE_COUNT)

func create_samples_bytes() -> PackedByteArray:
	var bytes = PackedInt32Array([samples_start]).to_byte_array()
	bytes.append_array(samples_data.to_byte_array());
	return bytes

var samples_bytes = create_samples_bytes()
var samples_buffer = device.storage_buffer_create(samples_bytes.size(), samples_bytes)
var samples_uniform = create_uniform(samples_buffer, 0)

func update_samples_buffer():
	samples_bytes = create_samples_bytes()
	device.buffer_update(samples_buffer, 0, samples_bytes.size(), samples_bytes)

const BIN_COUNT = 512
var dft = create_packed_vector2_array(BIN_COUNT)
var dft_bytes = dft.to_byte_array()
var dft_buffer = device.storage_buffer_create(dft_bytes.size(), dft_bytes)
var dft_uniform = create_uniform(dft_buffer, 1)

var uniform_set = device.uniform_set_create([samples_uniform, dft_uniform], dft_shader, 0)
var pipeline = device.compute_pipeline_create(dft_shader)

const GROUP_SIZE = 256
const GROUP_COUNT = 2 # BIN_COUNT / GROUP_SIZE

func calculate_dft():
	var compute_list = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	device.compute_list_dispatch(compute_list, GROUP_COUNT, 1, 1)
	device.compute_list_end()
	device.submit()
	device.sync()
	
	dft_bytes = device.buffer_get_data(dft_buffer)
	dft = dft_bytes.to_vector2_array()

const SAMPLE_RATE = 44100.0;
const LOWEST_FREQUENCY = SAMPLE_RATE / float(SAMPLE_COUNT);
const EXP_BINS = floor(BIN_COUNT / (log(SAMPLE_RATE / (2.0 * LOWEST_FREQUENCY)) / log(2.0)));

var period = 100.0
var focus = 0.5
var center_sample = 2048.0

func update_stabilization():
	var mx = 0.0
	var max_bin = 1
	for i in range(BIN_COUNT):
		var cur = dft[i].length()
		if cur > mx:
			mx = cur
			max_bin = i
		#mx = max(mx, dft[i].length())
	#while(max_bin < BIN_COUNT - 1 && 
		 #(dft[max_bin].length() < dft[max_bin + 1].length() || 
		  #dft[max_bin].length() < dft[max_bin - 1].length() || 
		  #dft[max_bin].length() < mx * 0.75)):
		#max_bin += 1;
	var frequency = pow(2, max_bin / EXP_BINS) * LOWEST_FREQUENCY;
	
	period = SAMPLE_RATE / frequency;
	var phase = dft[max_bin];
	var angle = atan2(phase.y, phase.x) / (PI * 2) - 0.25
	center_sample = (angle + ceil(SAMPLE_COUNT * focus / period)) * period

@export
var material : Material

func _process(_delta: float) -> void:
	var new_samples_count = capture.get_frames_available()
	var new_samples = capture.get_buffer(new_samples_count)
	for i in range(new_samples_count):
		samples_data.set((samples_start + i) % SAMPLE_COUNT, (new_samples[i].x + new_samples[i].y) * 0.5)
	samples_start = (samples_start + new_samples_count) % SAMPLE_COUNT
	update_samples_buffer()
	calculate_dft()
	update_stabilization()
	
	material.set_shader_parameter("samples_start", samples_start)
	material.set_shader_parameter("samples_data", samples_data)
	material.set_shader_parameter("dft", dft)
	material.set_shader_parameter("period", period)
	material.set_shader_parameter("focus", focus)
	material.set_shader_parameter("center_sample", center_sample)
