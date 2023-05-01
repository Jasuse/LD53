extends Node
@export var Scene : PackedScene

func switch_area():
	get_tree().change_scene_to_packed(Scene)

func _on_body_entered(body):
	if(body == GameInstance.player):
		get_tree().change_scene_to_packed(Scene)
