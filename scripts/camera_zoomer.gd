extends Node

@export var camera : Camera2D
@export var zoom : float
@export var duration : float = 1

func do_anim():
	print("anim")
	var tween = camera.create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom,zoom), duration)
	tween.play()
	queue_free()
