extends CharacterBody2D

# Speed and direction
@export var speed = 300
@export var gravity = 30
@export var jump_force = 700 # Godot defaults to have up be negative axis

func _physics_process(delta):
	
	#Vertical Movement
	if !is_on_floor() && (velocity.y <= 700):
		velocity.y += gravity
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force
	
	# Horizontal movement
	var horizontal_direction = Input.get_axis("move_left", "move_right")
	velocity.x = speed * horizontal_direction
	move_and_slide()
