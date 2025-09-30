extends RayCast3D

@onready var beam_mesh := $MeshInstance3D
@onready var collision_shape := $StaticBody3D/CollisionShape3D

var last_length := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision = CylinderShape3D.new()
	var mesh = CylinderMesh.new()
	collision_shape.shape = collision
	beam_mesh.mesh = mesh
	
	collision_shape.shape.radius = 0.02
	beam_mesh.mesh.top_radius = 0.01
	beam_mesh.mesh.bottom_radius = 0.01

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	force_raycast_update()
	
	var cast_point_y = -100
	var length = 100
	
	if is_colliding():
		cast_point_y = to_local(get_collision_point()).y
		length = abs(to_local(get_collision_point()).y)
	
	# Update mesh
	beam_mesh.mesh.height = cast_point_y
	beam_mesh.position.y = cast_point_y/2
	
	# Update collision
	if abs(last_length - length) > 0.01:
		collision_shape.shape.height = length
		collision_shape.position.y = cast_point_y/2
		
	last_length = length
