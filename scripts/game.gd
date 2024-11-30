extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids

var asteroid_scene = preload("res://scenes/asteroid.tscn")

var candidate : Vector2

func _ready() -> void:
	var screen_size = get_viewport_rect().size
	player.connect("laser_shot", _on_player_laser_shot)
	for i in range(5):
		var valid_asteroid = true
		while (valid_asteroid):
			candidate = Vector2(randi_range(0,screen_size.x), randi_range(0,screen_size.y))
			valid_asteroid = (candidate.distance_to(player.global_position ) <= 100)
		var a = asteroid_scene.instantiate()
		a.global_position = candidate
		a.size = "LARGE"
		a.connect("exploded", _on_asteroid_exploded)
		asteroids.add_child(a)
	#for asteroid in asteroids.get_children():
	#	asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser) 

func _on_asteroid_exploded(pos, size):
	for i in range(2):
		var a = asteroid_scene.instantiate()
		a.global_position = pos
		a.size = size
		a.connect("exploded", _on_asteroid_exploded)
		asteroids.call_deferred("add_child", a)
		#asteroids.add_child(a)
