extends CharacterBody3D

@export var launch_strength := 0.04
@export var max_drag_distance := 500
@export var gravity := 20.0
@export var friction := 0.9
@export var stop_threshold := 0.1
@export var tilt_multiplier := 0.5 # how much tilt during drag
@onready var compress_sound = $CompressSound
@onready var launch_sound = $LaunchSound
@onready var landing_sound = $LandingSound

var idle_timer := 5.0
var dragging := false
var drag_start: Vector2
var drag_current: Vector2
var anim_player: AnimationPlayer

func _ready():
	anim_player = $AnimationPlayer


func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if dragging:
		velocity.x = 0
		velocity.z = 0
		# Tilt based on drag
		var drag_vector = drag_start - drag_current
		var drag_dir = drag_vector.normalized()
		var target_tilt = clamp(-drag_dir.x * tilt_multiplier, -1.2, 1.2)
		rotation.z = lerp(rotation.z, target_tilt, 0.2)
	else:
		# Apply friction on horizontal movement
		velocity.x *= friction
		velocity.z *= friction
		# Stop tiny movement
		if Vector2(velocity.x, velocity.z).length() < stop_threshold:
			velocity.x = 0
			velocity.z = 0

		# Reset rotation if landed
		if is_on_floor():
			rotation.z = lerp(rotation.z, 0.0, 0.2)

	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_impulse(-c.get_normal() * 2)
			
	# Rewind input
	if Input.is_action_pressed("rewind_time"):
		for obj in get_tree().get_nodes_in_group("time_objects"):
			if not obj.rewinding:
				obj.start_rewind()
	if Input.is_action_just_released("rewind_time"):
		for obj in get_tree().get_nodes_in_group("time_objects"):
			if "stop_rewind" in obj:
				obj.stop_rewind()


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = event.position
			drag_current = drag_start
			if anim_player.has_animation("Compression"):
				anim_player.play("Compression")
			compress_sound.play()
		else:
			dragging = false
			_launch_from_drag()
			if anim_player.has_animation("IdleAnimation"):
				anim_player.play("IdleAnimation")
	elif dragging and event is InputEventMouseMotion:
		drag_current = event.position

func _launch_from_drag():
	var drag_vector = drag_start - drag_current
	var drag_length = min(drag_vector.length(), max_drag_distance)
	var drag_dir = drag_vector.normalized()
	launch_sound.play()

	# Convert drag vector to world velocity
	velocity = Vector3(drag_dir.x, -drag_dir.y, 0) * drag_length * launch_strength

func _process(delta: float) -> void:
	# Randomly play the IdleAnim2 ever 5 - 10 seconds
	idle_timer -= delta
	if idle_timer <= 0:
		if anim_player.has_animation("IdleAnim2"):
			anim_player.play("IdleAnim2")
			anim_player.queue("IdleAnimation")
		# reset timer
		idle_timer = randf_range(5.0, 10.0)
