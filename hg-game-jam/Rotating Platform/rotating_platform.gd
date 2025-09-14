extends AnimatableBody2D

@export var height : float = 200
@export var radius : float = 50
@export var speed_scale := 1.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var mesh_instance_2d: MeshInstance2D = $MeshInstance2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func  _ready() -> void:
	var collision = CapsuleShape2D.new()
	var mesh = CapsuleMesh.new()
	
	collision_shape_2d.shape = collision
	mesh_instance_2d.mesh = mesh
	
	collision_shape_2d.shape.radius = radius
	collision_shape_2d.shape.height = height
	
	mesh_instance_2d.mesh.radius = radius
	mesh_instance_2d.mesh.height = height
	
	animation.play("Rotate")
	animation.speed_scale = speed_scale
