extends CharacterBody2D

signal enemy_died
@export var Health : float = 40
@export var Speed : float = 200
@export var StopDistance : float = 180
@export var Damage : float = 10
@export var Delay : float = 0.3
var move_dir : Vector2
@onready var sprite_2d = $Sprite2D
@export var DeathPuddle : PackedScene
var next_attack : float
var time : float 
var mirrored : bool = false

@onready var enemy_death = $enemy_death
@onready var enemy_melee = $enemy_melee


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if(GameInstance.player):
		var dir = global_position.x - GameInstance.player.global_position.x
		if((dir < 0 && !mirrored) || (dir > 0 && mirrored)):
			apply_scale(Vector2(-1,1))
			mirrored = !mirrored
			
		if(global_position.distance_squared_to(GameInstance.player.global_position) >= StopDistance * StopDistance):
			move_dir = (GameInstance.player.global_position - global_position).normalized()
		else:
			move_dir = Vector2.ZERO
			if(next_attack < time && GameInstance.player.Health >= 0):
				GameInstance.player.take_damage(Damage)
				enemy_melee.play()
				print("attacking")
				next_attack = time + Delay

func _physics_process(delta):
	velocity = move_dir * Speed
	move_and_slide()

func _self_emit():
	print("emited")

func do_flash():
	sprite_2d.modulate = Color.INDIAN_RED
	var tween : Tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)
	tween.play()

func take_damage(dmg : float):
	Health -= dmg
	do_flash()
	if(Health <= 0):
		enemy_died.emit()
		var pud : Node2D = DeathPuddle.instantiate()
		get_tree().current_scene.add_child(pud)
		pud.global_position = global_position
		enemy_death.play()
		queue_free()
