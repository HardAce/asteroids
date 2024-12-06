extends RigidBody2D

signal laser_shot(laser)
@onready var muzzle01 = $Muzzle01
@onready var muzzle := [$Muzzle01, $Muzzle02, $Muzzle03, $Muzzle04]

var laser_scene := preload("res://scenes/lazer.tscn")

var shoot_cd := false
var fire_rate := 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and !shoot_cd:
		shoot_cd = true
		shoot_laser()
		await get_tree().create_timer(fire_rate).timeout
		shoot_cd = false
	
func shoot_laser() -> void:
	for i in muzzle:
		var l = laser_scene.instantiate()
		l.global_position = i.global_position
		l.rotation = rotation
		l.initial_movement = linear_velocity
		laser_shot.emit(l)
