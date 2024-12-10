extends Node2D

@onready var players = $Players
@onready var lasers = $Lasers
@onready var asteroids = $Asteroids
@onready var cruiser = $Enemies
@onready var hud = $UI/HUD

var player_scene = preload("res://scenes/player_2.tscn")
var asteroid_scene = preload("res://scenes/asteroid_2.tscn")
var lasers_scene = preload("res://scenes/lazer.tscn")
var cruiser_scene = preload("res://scenes/cruiser.tscn")

var candidate : Vector2

var score := 0:
	set(value):
		score = value
		hud.score = score

func _ready() -> void:
	score = 0
	var screen_size = get_viewport_rect().size
	var a = player_scene.instantiate()
	#var a = cruiser_scene.instantiate()
	a.connect("laser_shot", _on_player_laser_shot)
	var valid = true
	while (valid):
		candidate = Vector2(randi_range(0,screen_size.x), randi_range(0,screen_size.y))
		valid = false
	a.global_position = candidate
	players.add_child(a)
	
	"""
	a = crusier_scene.instantiate()
	a.connect("laser_shot", _on_cruiser_laser_shot)
	while (valid):
		candidate = Vector2(randi_range(0,screen_size.x), randi_range(0,screen_size.y))
		valid = false
	a.global_position = candidate
	cruiser.call_deferred("add_child", a)
	"""
	
	#players.call_deferred("add_child", a)
	#player2.connect("laser_shot", _on_player_laser_shot)
	#cruiser.connect("laser_shot", _on_cruiser_laser_shot)
	for i in range(50):
		valid = true
		while (valid):
			candidate = Vector2(randi_range(0,screen_size.x), randi_range(0,screen_size.y))
			valid = (candidate.distance_to(players.get_children()[0].global_position ) <= 100)
		a = asteroid_scene.instantiate()
		a.global_position = candidate
		a.size = "LARGE"
		a.connect("exploded", _on_asteroid_exploded)
		asteroids.call_deferred("add_child", a)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

func _on_player_laser_shot(laser) -> void:
	lasers.add_child(laser) 

func _on_asteroid_exploded(pos, size, points):
	score += points
	for i in range(2):
		var a = asteroid_scene.instantiate()
		a.global_position = pos
		a.size = size
		a.connect("exploded", _on_asteroid_exploded)
		asteroids.call_deferred("add_child", a)


func _on_cruiser_laser_shot(laser: Variant) -> void:
	lasers.call_deferred("add_child", laser)
