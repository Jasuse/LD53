extends Area2D

signal enemies_dead
@export var Enemies_Parent : Node
@export var EnemiesPrefab : Array[PackedScene]


var enemy_count : int = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_enemy_died():
	enemy_count -= 1
	print("enemy ded")
	if(enemy_count <= 0):
		emit_signal("enemies_dead")

func trigger():
	enemy_count = Enemies_Parent.get_child_count()
	for point in Enemies_Parent.get_children():
		var inst : Node2D = EnemiesPrefab.pick_random().instantiate()
		inst.enemy_died.connect(_on_enemy_died)
		point.call_deferred("add_child", inst)
	set_deferred("monitoring", false)

func _on_body_entered(body):
	if(body == GameInstance.player):
		enemy_count = Enemies_Parent.get_child_count()
		for point in Enemies_Parent.get_children():
			var inst : Node2D = EnemiesPrefab.pick_random().instantiate()
			inst.enemy_died.connect(_on_enemy_died)
			point.call_deferred("add_child", inst)
		set_deferred("monitoring", false)
