class_name Player extends CharacterBody2D

signal laser_shot(laser)

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 100.0
@export var inertia := 10.0

@onready var muzzle := $Muzzle

var laser_scene := preload("res://scenes/lazer.tscn")
var last_position := Vector2(0, -1)
var shoot_cd := false
var fire_rate := 0.3

func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot") and !shoot_cd:
		shoot_cd = true
		shoot_laser()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false
		
func _physics_process(delta: float) -> void:
	var input_vector := Vector2(0, Input.get_axis("move_forward","move_backward"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	print(velocity.length())
	
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed*delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed*delta))
	
	if Input.is_action_pressed("stop_inertia"):
		if abs(velocity.x) > 0:
			velocity.x -= sign(velocity.x) * (minf(inertia, abs(velocity.x)) * (abs(velocity.x) / (abs(velocity.x) + abs(velocity.y))))
		if abs(velocity.y) > 0:
			velocity.y -= sign(velocity.y) * (minf(inertia, abs(velocity.y)) * (abs(velocity.y) / (abs(velocity.x) + abs(velocity.y))))
	move_and_slide()
	
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
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * velocity.length())

func shoot_laser() -> void:
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	l.initial_movement = velocity
	laser_shot.emit(l)
