extends AnimationPlayer

func _on_area_2d_body_entered(body):
	if(body == GameInstance.player):
		body.controlled = true

		
		get_tree().create_timer(0.1).timeout.connect(func():
			body.animation_tree.active = false
			play("sequence")
			body.animation_tree.active = false

		
			body.animation_player.play("sequence_last"))
		
