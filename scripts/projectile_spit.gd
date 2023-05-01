extends Area2D

class_name ProjectileSpit

@export var Speed : float = 300
@export var Direction : Vector2 = Vector2.RIGHT
@export var Damage : float = 10
@export var Lifetime : float = 4
@export var IgnoreEnemy : bool = false
@export var SpitPrefab : PackedScene 

var parent : Node2D

var Initialized : bool = false
var time : float

func SpawnSpit():
	var spit = SpitPrefab.instantiate()
	get_tree().current_scene.add_child(spit)
	spit.global_position = global_position
	

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
			SpawnSpit()
			queue_free()


func _on_body_entered(body : Node2D):
	if(body != parent):
		if(IgnoreEnemy):
			if(body.is_in_group("enemy")):
				return
		if(body.has_method("take_damage")):
			body.take_damage(Damage)
			queue_free()
