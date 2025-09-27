extends RefCounted
class_name TimeBuffer

var size: int
var buffer: Array
var index: int = 0
var is_full: bool = false

func _init(capacity: int):
	size = capacity
	buffer = []
	buffer.resize(capacity)

func push(value):
	buffer[index] = value
	index = (index + 1) % size
	if index == 0:
		is_full = true

func rewind_frame():
	if is_full:
		index = (index - 1) % size
	else:
		index -= 1
		if index < 0:
			index = 0
