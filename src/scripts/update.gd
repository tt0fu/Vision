extends ColorRect

const SAMPLE_COUNT = 16384
var capture
var buffer := CircularFloatBuffer.new(SAMPLE_COUNT)


func _ready() -> void:
	capture = AudioServer.get_bus_effect(0, 0)
	
	#var rd := RenderingServer.create_local_rendering_device()
	#var shader_file := load("res://shaders/compute.glsl")
	#var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	#var shader := rd.shader_create_from_spirv(shader_spirv)
	#var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
	#var input_bytes := input.to_byte_array()
	#var comp_buf := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	#var uniform := RDUniform.new()
	#uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	#uniform.binding = 0
	#uniform.add_id(comp_buf)
	#var uniform_set := rd.uniform_set_create([uniform], shader, 0)
	#var pipeline := rd.compute_pipeline_create(shader)
	#var compute_list := rd.compute_list_begin()
	#rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	#rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	#rd.compute_list_dispatch(compute_list, 5, 1, 1)
	#rd.compute_list_end()
	#rd.submit()
	#rd.sync()
	#
	## Read back the data from the buffer
	#var output_bytes := rd.buffer_get_data(comp_buf)
	#var output := output_bytes.to_float32_array()
	#print("Input: ", input)
	#print("Output: ", output)
	

func _process(_delta: float) -> void:
	var new_sample_count = capture.get_frames_available()
	var samples = capture.get_buffer(new_sample_count)
	buffer.append(samples)
	get_material().set_shader_parameter("samples", buffer.get_buffer())
	get_material().set_shader_parameter("start", buffer.get_start())
