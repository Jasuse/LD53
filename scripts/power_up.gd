extends Node

@onready var sprite_2d = $Sprite2D
@export var amplitude : float = 300
@export var frequency : float =3
var init_pos : Vector2

func _ready():
	init_pos = sprite_2d.position

func _process(delta):
	sprite_2d.position.y = init_pos.y + amplitude * sin(Time.get_ticks_msec() / frequency)


func _on_body_entered(body):
	if(body == GameInstance.player):
		GameInstance.player.MaxHealth += 25
		GameInstance.player.Health += 25
		GameInstance.player.health_changed.emit(int(GameInstance.player.Health - 25), int(GameInstance.player.Health))
		queue_free()
