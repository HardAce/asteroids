extends Area2D

@export var speed := 500.0
@export var initial_movement : Vector2

var movement_vector := Vector2(0,-1)
var last_position := Vector2(0, -1)
var total_distance := 0.0
var total_time := 0.0

func _process(delta: float) -> void:
	last_position = self.global_position
	global_position += (initial_movement * delta) + (movement_vector.rotated(rotation) * speed * delta)
	total_distance += self.global_position.distance_to(last_position)
	total_time += delta
	
	if total_time > 1:
		queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
	
func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Asteroid_2:
		var asteroid = body
		asteroid.explode()
		queue_free()
