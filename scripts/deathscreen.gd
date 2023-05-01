extends Control
@onready var point_light_2d = $PointLight2D
@onready var button = $Button
@onready var button_2 = $Button2
@onready var label = $Label

func restart():
	get_tree().reload_current_scene()

func player_died():
	visible = true
	button.visible = false
	button_2.visible = false
	label.visible = false
	point_light_2d.position = GameInstance.player.get_global_transform_with_canvas().origin
	get_tree().create_timer(2).timeout.connect(func():
		button.visible = true
		button_2.visible = true
		label.visible = true)
