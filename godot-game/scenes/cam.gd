extends Camera3D

@export var target: Node3D
@export var distance: float = 3.0
@export var rotation_speed: float = 0.2

#mouse zoom
@export var zoom_speed: float = 1.0       # How much the distance changes with each wheel tick.
@export var min_distance: float = 1.0     # Minimum allowed distance from the target.
@export var max_distance: float = 3.0    # Maximum allowed distance from the target.

# Optional angle clamps to avoid flipping.
@export var min_pitch_degrees: float = -80.0
@export var max_pitch_degrees: float = 80.0

# Current rotation angles (in degrees).
var pitch := 0.0  # rotation around the x-axis
var yaw := 0.0    # rotation around the y-axis

func _ready() -> void:
	update_camera_transform()
	
func _process(_delta: float) -> void:
	update_camera_transform()

func _input(event: InputEvent) -> void:
	# Rotate the camera only when the right mouse button is pressed.
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * rotation_speed
		pitch -= event.relative.y * rotation_speed
		pitch = clamp(pitch, min_pitch_degrees, max_pitch_degrees)
		update_camera_transform()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(distance - zoom_speed, min_distance)
			update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(distance + zoom_speed, max_distance)
			update_camera_transform()

func update_camera_transform() -> void:
	if not target:
		return
	
	# Convert pitch & yaw from degrees to radians.
	var pitch_radians = deg_to_rad(pitch)
	var yaw_radians = deg_to_rad(yaw)
	
	# Create a Basis that first rotates by yaw around Y, then pitch around X.
	var camera_basis = Basis()
	camera_basis = Basis(Vector3.UP, yaw_radians) * Basis(Vector3.RIGHT, pitch_radians)
	
	# By default, the camera "points" down -Z. We want it offset by distance along -Z.
	var camera_offset = camera_basis * Vector3(0, 0, distance)
	
	# Set the camera’s global position to target’s position + the offset.
	global_transform.origin = target.global_transform.origin + camera_offset
	
	# Make the camera look at the target’s position. Vector3.UP indicates the up direction.
	look_at(target.global_transform.origin, Vector3.UP)
