extends RigidBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 150.0
@export var max_spin := 1.0
@export var rotation_speed := 100.0
@export var engine_power = 8000
@export var spin_power = 50000

@onready var screensize = get_viewport_rect().size
@onready var muzzle := $Muzzle

var laser_scene := preload("res://scenes/lazer.tscn")
var last_position := Vector2(0, -1)
var shoot_cd := false
var fire_rate := 0.3
var thrust = Vector2.ZERO
var rotation_dir = 0

func _process(_delta: float) -> void:
	get_viewport().get_mouse_position()
	if Input.is_action_pressed("shoot") and !shoot_cd:
		shoot_cd = true
		shoot_laser()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false

func _physics_process(delta: float) -> void:
	get_input()
	
	if Input.is_action_pressed("stop_inertia"):
		angular_damp += 12 * delta
		linear_damp += 12 * delta
	else:
		linear_damp = 0
		angular_damp = 0
	
	if not(Input.is_action_pressed("rotate_left") or Input.is_action_pressed("rotate_right")):
		angular_damp += 12
	
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	last_position = self.global_position

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var xform = state.transform
	xform.origin.x = wrapf(xform.origin.x, 0 - 49, screensize.x + 49)
	xform.origin.y = wrapf(xform.origin.y, 0 - 38, screensize.y + 38)
	if state.linear_velocity.length()>max_speed:
		state.linear_velocity=state.linear_velocity.normalized()*max_speed
	angular_velocity = (fposmod( (get_global_mouse_position() - global_position ).angle() - global_rotation + PI + PI/2, PI * 2 ) - PI) / .01
	if abs(state.angular_velocity) > max_spin:
		state.angular_velocity = max_spin * (state.angular_velocity / abs(state.angular_velocity))
	"""
https://www.reddit.com/r/godot/comments/e16krk/smooth_look_at_for_2d/

set_angular_velocity((get_angle_to(get_global_mouse_position())) * -((get_angle_to(get_global_mouse_position())) -3.14) * 5)

nodeToTurn.angular_velocity = (fposmod( (targetPosition - currentPosition).angle() - currentRotation + PI, PI * 2 ) - PI) / turnTime

func SmoothLookAtRigid( nodeToTurn, targetPosition, turnSpeed ):
	nodeToTurn.angular_velocity = AngularLookAt( nodeToTurn.global_position, nodeToTurn.global_rotation, targetPosition, turnSpeed )
func AngularLookAt( currentPosition, currentRotation, targetPosition, turnTime ):
	return GetAngle( currentRotation, TargetAngle( currentPosition, targetPosition ) )/turnTime
func TargetAngle( currentPosition, targetPosition ):
	return (targetPosition - currentPosition).angle()
func GetAngle( currentAngle, targetAngle ):
	return fposmod( targetAngle - currentAngle + PI, PI * 2 ) - PI
	"""
	state.transform = xform

func get_input():
	
	thrust = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		thrust = -transform.y * engine_power
	
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	

func shoot_laser() -> void:
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	l.initial_movement = linear_velocity
	laser_shot.emit(l)
