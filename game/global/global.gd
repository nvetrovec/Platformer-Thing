extends Node

onready var _root = get_tree().get_root()

func _ready():
	_root.connect("size_changed", self, "_resize")
	
	set_process_input(true)

func _resize():
	print(_root.get_rect())

func _input(event):
	if (event.is_pressed() and event.type == InputEvent.KEY and event.scancode == KEY_ESCAPE):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
