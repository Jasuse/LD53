extends CharacterBody2D

signal enemy_died
@export var Health : float = 40
@export var Speed : float = 200
@export var StopDistance : float = 500
@export var Bullet : PackedScene
@export var Damage : float = 10
@export var Delay : float = 0.3
var move_dir : Vector2
@onready var sprite_2d = $Sprite2D

@export var DeathPuddle : PackedScene
@onready var mouth = $Mouth
@onready var shoot_mouth = $ShootMouth

var next_attack : float
var time : float 
var mirrored : bool = false


func switch_mouth_state(state : bool):
	shoot_mouth.visible = state
	mouth.visible = !state

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
			if( abs(GameInstance.player.global_position.y - global_position.y) > 40):
				var vdir = 1 if GameInstance.player.global_position.y - global_position.y > 0 else -1
				move_dir = Vector2(0, vdir)
				return
			move_dir = Vector2.ZERO
			if(next_attack < time):
				var inst = Bullet.instantiate()
				get_tree().current_scene.add_child(inst)
				inst.global_position = shoot_mouth.global_position
				var direction = global_position.x - GameInstance.player.global_position.x
				inst.Initialize(self, -1 if direction > 0 else 1)
				switch_mouth_state(true)
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
		queue_free()
