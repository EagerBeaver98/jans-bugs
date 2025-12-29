extends Camera3D

@export var orbit_sensitivity := 0.005
@export var orbit_distance := 8.0
@export var camera_collision_margin := 0.5  # Distance to maintain from ground
@export var zoom_sensitivity := 0.5  # How fast scroll wheel changes distance
@export var min_orbit_distance := 2.0  # Closest zoom
@export var max_orbit_distance := 20.0  # Farthest zoom

var is_orbiting := false
var orbit_yaw := 0.0
var orbit_pitch := 0.45  # radians, ~25 degrees for pleasant default view
var last_mouse_pos := Vector2.ZERO
var ground_node: Node3D


func _ready() -> void:
	# Get reference to ground node for collision detection
	ground_node = get_parent().get_parent().get_node("Ground")
	# Initialize camera position based on orbit angles
	_update_orbit_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_orbiting = event.pressed
			if is_orbiting:
				last_mouse_pos = get_viewport().get_mouse_position()
			get_viewport().set_input_as_handled()
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			orbit_distance -= zoom_sensitivity
			orbit_distance = clamp(orbit_distance, min_orbit_distance, max_orbit_distance)
			_update_orbit_position()
			get_viewport().set_input_as_handled()
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			orbit_distance += zoom_sensitivity
			orbit_distance = clamp(orbit_distance, min_orbit_distance, max_orbit_distance)
			_update_orbit_position()
			get_viewport().set_input_as_handled()
	
	elif event is InputEventMouseMotion and is_orbiting:
		var mouse_delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		
		# Apply mouse movement to orbit angles
		orbit_yaw -= mouse_delta.x * orbit_sensitivity
		orbit_pitch -= -(mouse_delta.y) * orbit_sensitivity
		
		# Clamp pitch to prevent flipping
		orbit_pitch = clamp(orbit_pitch, -PI / 2.5, PI / 2.5)
		
		_update_orbit_position()
		get_viewport().set_input_as_handled()


func _update_orbit_position() -> void:
	# Calculate orbital position relative to player center
	var orbital_offset = Vector3(
		sin(orbit_yaw) * cos(orbit_pitch),
		sin(orbit_pitch),
		cos(orbit_yaw) * cos(orbit_pitch)
	) * orbit_distance
	
	# Check for collision with ground and adjust position if needed
	var adjusted_offset = _check_ground_collision(orbital_offset)
	
	position = adjusted_offset
	look_at(Vector3.ZERO, Vector3.UP)


func _check_ground_collision(offset: Vector3) -> Vector3:
	# Get player world position (parent of camera in world space)
	var player_world_pos = get_parent().global_position
	var target_world_pos = player_world_pos + offset
	
	# Raycast from player to camera position to detect ground collision
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(player_world_pos, target_world_pos)
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		# Hit something, pull camera back along the offset direction
		var hit_distance = player_world_pos.distance_to(result.position)
		var desired_distance = hit_distance - camera_collision_margin
		
		# Clamp to prevent camera from going inside player
		desired_distance = max(desired_distance, 1.0)
		
		var adjusted_offset = offset.normalized() * desired_distance
		return adjusted_offset
	
	return offset
