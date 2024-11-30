extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids

var asteroid_scene = preload("res://scenes/asteroid.tscn")

func _ready() -> void:
	player.connect("laser_shot", _on_player_laser_shot)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size):
	for i in range(2):
		var a = asteroid_scene.instantiate()
		a.global_position = pos
		a.size = size
		a.connect("exploded", _on_asteroid_exploded)
		asteroids.add_child(a)
