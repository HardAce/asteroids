extends RigidBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 100.0
@export var engine_power = 800
@export var spin_power = 10000

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
	var input_vector := Vector2(0, Input.get_axis("move_forward","move_backward"))
	
	linear_velocity += input_vector.rotated(rotation) * acceleration
	linear_velocity.limit_length(max_speed)
	
	if Input.is_action_pressed("escape"):
		get_tree().quit()
	
	thrust = Vector2.ZERO
	
	if (Input.is_action_just_released("rotate_left") or Input.is_action_just_released("rotate_right")):
		lock_rotation = true
	else:
		lock_rotation = false
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
	if Input.is_action_pressed("stop_inertia"):
		angular_damp += 12 * delta
		linear_damp += 12 * delta
		#print(linear_damp)
	else:
		linear_damp = 0
		angular_damp = 0
	
	last_position = self.global_position
	
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	if global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	if global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser() -> void:
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	l.initial_movement = linear_velocity
	laser_shot.emit(l)
