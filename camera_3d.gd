extends Camera3D

@export var orbit_sensitivity := 0.005
@export var orbit_distance := 8.0

var is_orbiting := false
var orbit_yaw := 0.0
var orbit_pitch := 0.45  # radians, ~25 degrees for pleasant default view
var last_mouse_pos := Vector2.ZERO


func _ready() -> void:
	# Initialize camera position based on orbit angles
	_update_orbit_position()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_orbiting = event.pressed
			if is_orbiting:
				last_mouse_pos = get_viewport().get_mouse_position()
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
	
	position = orbital_offset
	look_at(Vector3.ZERO, Vector3.UP)
