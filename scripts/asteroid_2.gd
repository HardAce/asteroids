class_name Asteroid_2 extends RigidBody2D

signal exploded(pos, size)

var movement_vector := Vector2(0, -1)
var speed : float
var direction : float

enum AsteroidSize{LARGE, MEDIUM, SMALL, TINY}

@export var size := AsteroidSize.LARGE

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

func _ready() -> void:
	rotation = randf_range(0, 2*PI)
	direction = randf_range(0, 2*PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50.0, 100.0)
			mass = 50
			set_linear_velocity(Vector2(speed,0).rotated(randf() * 2.0 * PI))
			set_angular_velocity(randf_range(-.5*PI, .5*PI))
			cshape.shape = preload("res://resources/asteroid_cshape_large1.tres")
			if randi_range(0,1) == 0:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_big1.png")
			else:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_big1.png")
			
		AsteroidSize.MEDIUM:
			speed = randf_range(100.0, 150.0)
			mass = 25
			set_linear_velocity(Vector2(speed,0).rotated(randf() * 2.0 * PI))
			cshape.shape = preload("res://resources/asteroid_cshape_medium1.tres")
			if randi_range(0,1) == 0:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_med1.png")
			else:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_med1.png")
		
		AsteroidSize.SMALL:
			speed = randf_range(150.0, 200.0)
			mass = 10
			set_linear_velocity(Vector2(speed,0).rotated(randf() * 2.0 * PI))
			cshape.shape = preload("res://resources/asteroid_cshape_small1.tres")
			if randi_range(0,1) == 0:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_small1.png")
			else:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_small1.png")
		
		AsteroidSize.TINY:
			speed = randf_range(150.0, 200.0)
			set_linear_velocity(Vector2(speed,0).rotated(randf() * 2.0 * PI))
			cshape.shape = preload("res://resources/asteroid_cshape_tiny1.tres")
			if randi_range(0,1) == 0:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorBrown_tiny1.png")
			else:
				sprite.texture = preload("res://assets/PNG/Meteors/meteorGrey_tiny1.png")

func _physics_process(_delta: float) -> void:
	pass
	#global_position += movement_vector.rotated(direction) * speed * delta
	#rotation += delta
	
"""
	
	var screen_size = get_viewport_rect().size
	
	if (global_position.y + cshape.shape.radius) < 0:
		global_position.y = (screen_size.y + cshape.shape.radius)
	elif (global_position.y - cshape.shape.radius) > screen_size.y:
		global_position.y = -cshape.shape.radius
	if (global_position.x + cshape.shape.radius) < 0:
		global_position.x = (screen_size.x + cshape.shape.radius)
	elif (global_position.x - cshape.shape.radius) > screen_size.x:
		global_position.x = -cshape.shape.radius
"""

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var screensize = get_viewport_rect().size
	var xform = state.transform
	
	xform.origin.x = wrapf(xform.origin.x, 0 - (sprite.texture.get_width()/2), screensize.x + (sprite.texture.get_width()/2))
	xform.origin.y = wrapf(xform.origin.y, 0 - (sprite.texture.get_height()/2), screensize.y + (sprite.texture.get_height()/2))
	
	state.transform = xform

func _on_body_entered(_body: Node2D) -> void:
	pass

func explode():
	var new_size
	var points := 100
	match size:
		AsteroidSize.LARGE:
			new_size = AsteroidSize.MEDIUM
		AsteroidSize.MEDIUM:
			new_size = AsteroidSize.SMALL
		AsteroidSize.SMALL:
			#new_size = AsteroidSize.TINY
			queue_free()
			return
		AsteroidSize.TINY:
			queue_free()
			return
	exploded.emit(global_position, new_size, points)
	queue_free()
