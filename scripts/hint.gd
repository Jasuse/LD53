extends Node


func _ready():
	get_tree().paused = true

func _unhandled_input(event):
	if(Input.is_action_just_pressed("fire")):
		get_tree().paused = false
		queue_free()

