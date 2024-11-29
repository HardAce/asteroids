extends Area2D

@export var speed := 500.0
@export var range := 500.0
@export var initial_movement : Vector2

var movement_vector : Vector2
var last_position := Vector2(0, -1)
var total_distance := 0.0

func _physics_process(delta):
	last_position = self.global_position
	global_position += initial_movement + (movement_vector.rotated(rotation) * speed * delta)
	total_distance += self.global_position.distance_to(last_position)
	
	if total_distance >= range:
		queue_free()
