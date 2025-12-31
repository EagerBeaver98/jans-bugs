class_name Player extends CharacterBody3D

@export var speed := 10
@export var fall_acceleration := 100
var orientation = Transform3D()

var target_velocity := Vector3.ZERO

func _physics_process(delta):
	var input_direction := Vector3.ZERO
	
	#Player input

	if Input.is_action_pressed("move_forward"):
		input_direction.z -= 1
	if Input.is_action_pressed("move_back"):
		input_direction.z += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	var jump_impulse := 0.0
	if Input.is_action_pressed("jump"):
		jump_impulse = 3.0

	# Compute camera-relative movement so "forward" moves away from camera
	var move_dir := Vector3.ZERO
	var cam := get_node_or_null("Camera3D")
	if cam:
		var cam_forward = (global_position - cam.global_position)
		cam_forward.y = 0
		if cam_forward.length() > 0.001:
			cam_forward = cam_forward.normalized()
		else:
			cam_forward = -transform.basis.z
		var cam_right = cam_forward.cross(Vector3.UP).normalized()
		move_dir = cam_forward * (-input_direction.z) + cam_right * input_direction.x
		if move_dir != Vector3.ZERO:
			move_dir = move_dir.normalized()
			$Pivot.look_at(global_position + move_dir, Vector3.UP)
	else:
		if input_direction != Vector3.ZERO:
			input_direction = input_direction.normalized()
			$Pivot.basis = Basis.looking_at(input_direction)

	# Ground / horizontal velocity
	target_velocity.x = move_dir.x * speed
	target_velocity.z = move_dir.z * speed

	# Vertical (jump/fall)
	target_velocity.y = jump_impulse

	#Vertical velocity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	
	#Moving the character
	velocity = target_velocity
	move_and_slide()
