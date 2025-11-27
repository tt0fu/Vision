extends Control

var mat = get_material()

func _process(_delta: float) -> void:
	mat.set_shader_parameter("scale_x", size.x / size.y)
