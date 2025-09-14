extends Path2D

@export var loop := true
@export var speed := 2.0
@export var speed_scale := 1.0 
@export var platform_x : float = 100
@export var platform_y : float = 100

@onready var path: PathFollow2D = $PathFollow2D
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance_2d: MeshInstance2D = $AnimatableBody2D/MeshInstance2D
@onready var collision_shape_2d: CollisionShape2D = $AnimatableBody2D/CollisionShape2D

func  _ready() -> void:
	var collision = RectangleShape2D.new()
	var mesh = QuadMesh.new()
	
	collision_shape_2d.shape = collision
	mesh_instance_2d.mesh = mesh
	
	collision_shape_2d.shape.size = Vector2(platform_x, platform_y)
	mesh_instance_2d.mesh.size = Vector2(platform_x, platform_y)
	if not loop:
		animation.play("move")
		animation.speed_scale = speed_scale
		set_process(false)
	

func _process(delta: float) -> void:
	path.progress += speed
