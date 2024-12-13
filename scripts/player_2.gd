extends RigidBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 100.0
@export var engine_power = 800
@export var spin_power = 10000

@onready var screensize = get_viewport_rect().size
@onready var muzzle := $Muzzle

var laser_scene := preload("res://scenes/lazer.tscn")
var last_position := Vector2(0, -1)
var shoot_cd := false
var fire_rate := 0.3
var thrust = Vector2.ZERO
var rotation_dir = 0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and !shoot_cd:
		shoot_cd = true
		shoot_laser()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false

func _physics_process(delta: float) -> void:
	get_input()
	
	"""
	linear_velocity += input_vector.rotated(rotation) * acceleration
	linear_velocity.limit_length(max_speed)
	
	thrust = Vector2.ZERO
	
	if (Input.is_action_just_released("rotate_left") or Input.is_action_just_released("rotate_right")):
		lock_rotation = true
	else:
		lock_rotation = false
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	"""
	
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
