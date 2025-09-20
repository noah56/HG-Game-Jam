extends RigidBody2D
class_name BaseMovableObject

const TimeBuffer = preload("res://Time Buffer/time_buffer.gd")
@export var buffer_size := 1800 # ~30 seconds if you record at 60fps
@export var rewind_speed := 1.0 # 1.0 = real-time rewind

var time_buffer: TimeBuffer
var rewinding := false

func _ready():
	time_buffer = TimeBuffer.new(buffer_size)

func _physics_process(delta):
	if rewinding == false:
		_record_step()

func _record_step():
	if rewinding:
		return
		
	var state = {
		"position": global_position,
		"rotation": rotation
	}
		
	var previous_state = time_buffer.buffer[time_buffer.index - 1]
	if not previous_state:
		time_buffer.push(state)
		return
		
	if JSON.stringify(previous_state.position) != JSON.stringify(state.position):
		time_buffer.push(state)

func start_rewind():
	rewinding = true
	sleeping = false

func stop_rewind():
	rewinding = false
	sleeping = true
	# Allow Godot to resume control of sleeping
	apply_central_impulse(Vector2(0, 0))
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not rewinding:
		return # normal physics takes over
	
	time_buffer.rewind_frame()
	var new_state = time_buffer.buffer[time_buffer.index]
	if new_state == null:
		return

	state.transform = Transform2D(new_state.rotation, new_state.position)
	state.linear_velocity = Vector2(0.0, 0.0)
	state.angular_velocity = 0.0
