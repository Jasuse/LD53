extends Node2D

@export var camera : Camera2D
@export var offsetX : float = 300
@export var duration : float = 1

func do_anim():
	var tween = camera.create_tween()
	tween.tween_property(camera, "position:x", global_position.x + offsetX, duration)
	tween.play()
	queue_free()

