extends RigidBody3D
class_name BaseMovableObject3D

@export var buffer_size := 1800 # ~30 seconds at 60fps

var time_buffer: TimeBuffer
var rewinding := false

func _ready():
	time_buffer = TimeBuffer.new(buffer_size)

func _physics_process(delta: float) -> void:
	if not rewinding:
		_record_step()

func _record_step():
	if rewinding:
		return
	
	var state = {
		"position": global_transform.origin,   # Vector3
		"basis": global_transform.basis       # full 3D rotation
	}
	
	var previous_state = time_buffer.buffer[time_buffer.index - 1]
	if not previous_state:
		time_buffer.push(state)
		return
	
	if previous_state.position != state.position or previous_state.basis != state.basis:
		time_buffer.push(state)

func start_rewind():
	rewinding = true
	sleeping = false

func stop_rewind():
	rewinding = false
	sleeping = true
	# Wake physics back up with a zero impulse
	apply_impulse(Vector3.ZERO)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not rewinding:
		return # normal physics takes over
	
	time_buffer.rewind_frame()
	var new_state = time_buffer.buffer[time_buffer.index]
	if new_state == null:
		return
	
	# Reconstruct full transform
	var t = Transform3D()
	t.origin = new_state.position
	t.basis = new_state.basis
	state.transform = t
	
	# Freeze motion during rewind
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO
