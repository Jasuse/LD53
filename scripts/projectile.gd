extends Area2D

class_name Projectile

@export var Speed : float = 600
@export var Direction : Vector2 = Vector2.RIGHT
@export var Damage : float = 10
@export var Lifetime : float = 2
@export var IgnoreEnemy : bool = false

signal hit_enemy
var parent : Node2D

var Initialized : bool = false
var time : float

func Initialize(_parent : Node2D, direction : float):
	parent = _parent
	print(_parent.scale.x)
	Direction  = Vector2(direction, 0)
	Initialized = true
	monitoring = true
	z_index = global_position.y * 0.1
	
func _physics_process(delta):
	if(Initialized):
		time += delta
		global_position += Direction * Speed * delta
		if(time > Lifetime):
			queue_free()


func _on_body_entered(body : Node2D):
	if(body != parent):
		if(IgnoreEnemy):
			if(body.is_in_group("enemy")):
				return
		if(body.has_method("take_damage")):
			body.take_damage(Damage)
			hit_enemy.emit()
			queue_free()
