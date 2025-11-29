extends Node

@export
var scenes : Array[CanvasLayer] = []

var index = 0;

func update():
	for i in range(scenes.size()):
		scenes[i].set_process_mode(ProcessMode.PROCESS_MODE_DISABLED);
		scenes[i].set_visible(false);
	scenes[index].set_process_mode(ProcessMode.PROCESS_MODE_INHERIT);
	scenes[index].set_visible(true);

func _ready():
	update();

func _input(event):
	if event is InputEventKey && event.pressed:
		var key = event.keycode
		if key >= KEY_1 && key <= KEY_9 && key - KEY_1 < scenes.size():
			index = key - KEY_1
			update();
