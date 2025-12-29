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
	if Input.is_action_pressed("jump"):
		input_direction.y += 3
	
	if input_direction != Vector3.ZERO:
		input_direction = input_direction.normalized()

		$Pivot.basis = Basis.looking_at(input_direction)

	#Ground velocity
	target_velocity.x = input_direction.x * speed
	target_velocity.z = input_direction.z * speed
	target_velocity.y = input_direction.y * speed

	#Vertical velocity
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	
	#Moving the character
	velocity = target_velocity
	move_and_slide()