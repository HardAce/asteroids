extends Control

@onready var asteroid_count = $Label2
@onready var slider = $HSlider

func _process(_delta: float) -> void:
	
	asteroid_count.text = str(slider.step)
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_start_button_2_pressed() -> void:
	get_tree().quit()
