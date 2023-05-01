extends Area2D

@export var Damage : float = 20
@export var Delay : float = 0.3
@export var Lifetime : float = 2
var next_attack : float = 0
var time : float = 0
#@onready var animation_player = $AnimationPlayer
var player_in : bool


func _process(delta):
	time += delta
	if(time > Lifetime):
		queue_free()
		
	if(player_in && next_attack < time):
		GameInstance.player.take_damage(Damage)
		next_attack = time + Delay
		print("spit attak")
		
func _on_body_entered(body):
	if(body == GameInstance.player):
		player_in = true
			


func _on_body_exited(body):
	if(body == GameInstance.player):
		player_in = false
