extends KinematicBody

# Mouse Look
onready var cam = $Camera
export var h_mouse_sense : float = 1
export var v_mouse_sense : float = 1
export var min_cam_pitch : float = -90
export var max_cam_pitch : float = 90
export var cam_tilt_multiplier = 0.2
var mouse_sense_multiplier : float = 0.05

# Keyboard Movement
var input_vector : Vector3 = Vector3.ZERO
var velocity : Vector3 = Vector3.ZERO
export var walk_move_speed : float = 6
export var walk_acceleration : float = 15
export var jump_impulse : float = 2.5
export var gravity : float = 9.83
var snap_vector = Vector3.ZERO
var gravity_vector = Vector3.DOWN


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _do_camera_tilt(delta):
	cam.rotation_degrees.z = transform.basis.tdotx(velocity * cam_tilt_multiplier)


func _process(delta):
	_do_camera_tilt(delta)


func _do_mouse_look(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * h_mouse_sense * mouse_sense_multiplier))
		cam.rotate_x(deg2rad(event.relative.y * v_mouse_sense * mouse_sense_multiplier))
		cam.rotation.x = clamp(cam.rotation.x, deg2rad(min_cam_pitch), deg2rad(max_cam_pitch))


func _unhandled_input(event):
	_do_mouse_look(event)


func _get_input_vector():
	input_vector.z = Input.get_axis("move_back", "move_forward")
	input_vector.x = Input.get_axis("move_right", "move_left")
	input_vector = Vector3(input_vector.x, 0, input_vector.z).normalized().rotated(Vector3.UP, rotation.y)


func _apply_movement(delta):
	velocity = velocity.linear_interpolate(input_vector * walk_move_speed, walk_acceleration * delta)
	velocity = move_and_slide_with_snap(velocity + gravity_vector, snap_vector, Vector3.UP, true)


func _apply_gravity(delta):
	if !is_on_floor():
		gravity_vector += Vector3.DOWN * gravity * delta
	else:
		gravity_vector = Vector3.ZERO


func _apply_snap_vector():
	if is_on_floor():
		snap_vector = -get_floor_normal()
	else:
		snap_vector = Vector3.DOWN


func _do_jump():
	if is_on_floor() && Input.is_action_just_pressed("jump"):
		snap_vector = Vector3.ZERO
		gravity_vector = Vector3.UP * jump_impulse


func _physics_process(delta):
	_get_input_vector()
	_apply_movement(delta)
	_apply_gravity(delta)
	_apply_snap_vector()
	_do_jump()
