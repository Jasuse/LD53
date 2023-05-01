extends CharacterBody2D

signal health_changed(oldHP, newHP)
signal player_died

@export var Speed : float = 300
@export var Damage : float = 20
@export var Bullet : PackedScene
@export var Delay : float = 0.3
@export var MaxHealth : float = 125
@export var Health : float = 100
@export var ShootPos : Node2D
@export var IFrameMultiplier : float = 0.2
@export var HitToRegen : int = 4
@export var AbilityCD : float = 2
@export var HeavyBootsTime : float = 10
@onready var animation_tree = $AnimationTree
@onready var body = $Body


@onready var animation_player = $AnimationPlayer
@onready var hand_polygon = $HandPolygon
@onready var left_leg_polygon = $LeftLegPolygon
@onready var right_leg_polygon = $RightLegPolygon
 
@onready var leftboots = $LeftLegSkeleton/UpperLeg/LowerLeg/Boots
@onready var rightboots = $RightLegSkeleton/UpperLeg/LowerLeg/Boots


var controlled : bool = false
var dir : Vector2
var next_shoot : float = 0
var next_ability : float = 0
var boots_timeout : float = 0
var wantShoot : bool = false
var wantAlt : bool = false
var wantAb1 : bool = false
var wantAb2 : bool = false
var time : float = 0

var mirrored : bool = false

var next_damage : float
var current_hits : int = 0

var has_heavy_boots : bool = false

@onready var fist_area :Area2D= $FistArea
@onready var laser_ray_cast:Area2D = $LaserRayCast
@onready var boots_area:Area2D = $BootsArea
@onready var boots_particles : CPUParticles2D = $CPUParticles2D2


func _init():
	GameInstance.player = self

func _ready():
	get_tree().create_timer(0.01).timeout.connect(func() : health_changed.emit(int(Health), int(Health)))

func do_knock_anim():
	animation_tree.active = false
	animation_player.play("RESET")
	get_tree().create_timer(0.1).timeout.connect(func():
		animation_player.play("knock_animation"))
	#animation_player.play("offer_package")
	
func do_offer(backward : bool):
	print("doing offer")
	if(backward):
		animation_player.play("put_back_package")
	else:
		animation_player.play("offer_package")


func enable_animtree():
	animation_tree.active = true
	hand_polygon.visible = true

func _input(event):
	dir.x = Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("move_up", "move_down")
	wantShoot = Input.is_action_pressed("fire")
	wantAlt = Input.is_action_pressed("alt_fire")
	wantAb1 = Input.is_action_just_pressed("ability_1")
	wantAb2 = Input.is_action_just_pressed("ability_2")
	
	if((dir.x != 0 || dir.y != 0) && !controlled):
		animation_tree.set("parameters/Moving/blend_amount", 1)
	else:
		animation_tree.set("parameters/Moving/blend_amount", 0)

func _shoot_laser():
	var bodies = laser_ray_cast.get_overlapping_bodies()
	for body in bodies:
		if(body != self):
			if(body.has_method("take_damage")):
				body.take_damage(50)

func _do_shockwave():
	var bodies = fist_area.get_overlapping_bodies()
	for body in bodies:
		if(body != self):
			if(body.has_method("take_damage")):
				var dist = body.global_position.distance_to(fist_area.global_position)
				var damage = 70 - dist * 0.01
				body.take_damage(damage)

func _boots_shockwave():
	var bodies = boots_area.get_overlapping_bodies()
	boots_particles.emitting = true
	for body in bodies:
		if(body != self):
			if(body.has_method("take_damage")):
				var dist = body.global_position.distance_to(fist_area.global_position)
				var damage = 20 - dist * 0.01
				body.take_damage(damage)

func _process(delta):
	time += delta
	if(controlled || Health <= 0):
		return
	
	if(has_heavy_boots && boots_timeout < time):
		animation_tree.set("parameters/RunStateMachine/conditions/heavy_boots", false)
		has_heavy_boots = false
		print("has no boots (")
		leftboots.visible = false
		rightboots.visible = false
		left_leg_polygon.visible = true
		right_leg_polygon.visible = true
		hand_polygon.visible = true
			
	if(wantShoot):
		if(next_shoot < time):
			var inst : Projectile = Bullet.instantiate()
			get_tree().current_scene.add_child(inst)
			inst.global_position = ShootPos.global_position
			inst.Initialize(self, -1 if mirrored else 1)
			inst.hit_enemy.connect(projectile_hit)
			next_shoot = time + Delay
			animation_tree.set("parameters/Shoot/request", 1)
	
	if(wantAlt && (Health - 125 >= 0)):
		if(next_shoot < time && next_ability < time):
			next_shoot = time + AbilityCD
			next_ability = time + AbilityCD
			animation_tree.set("parameters/LaserShoot/request", 1)
			health_changed.emit(int(Health), int(Health - 25))
			Health -= 25
	
	if(wantAb1 && (Health - 150 >= 0)):
		if(next_shoot < time && next_ability < time):
			next_shoot = time + AbilityCD
			next_ability = time + AbilityCD
			animation_tree.set("parameters/FistAttack/request", 1)
			health_changed.emit(int(Health), int(Health - 50))
			Health -= 50
			
	if(wantAb2 && (Health - 175 >= 0)):
		if(next_shoot < time && next_ability < time):
			next_shoot = time + AbilityCD + HeavyBootsTime - 0.1
			next_ability = time + AbilityCD + HeavyBootsTime
			has_heavy_boots = true
			leftboots.visible = true
			rightboots.visible = true
			left_leg_polygon.visible = false
			right_leg_polygon.visible = false
			hand_polygon.visible = false
			health_changed.emit(int(Health), int(Health - 75))
			boots_timeout = time + HeavyBootsTime
			animation_tree.set("parameters/RunStateMachine/conditions/heavy_boots", true)
			Health -= 75
	
func _physics_process(delta):
	if(controlled || Health <= 0):
		return
	
	if( (dir.x < 0 && !mirrored) || (dir.x > 0 && mirrored)):
		var newscale = Vector2(-1, 1)
		apply_scale(newscale)
		mirrored = !mirrored
	velocity = dir * Speed
	move_and_slide()

func projectile_hit():
	current_hits += 1
	if(current_hits >= HitToRegen):
		do_flash(Color.DARK_GREEN)
		var oldHP = Health
		Health += Damage * 0.5
		Health = min(MaxHealth, Health)
		health_changed.emit(int(oldHP), int(Health))
		current_hits = 0

func do_flash(color : Color):
	body.modulate = color
	var tween : Tween = create_tween()
	tween.tween_property(body, "modulate", Color.WHITE, 0.4)


func do_death():
	animation_tree.active = false
	animation_player.play("die")

func take_damage(dmg : float):
	if(Health <= 0):
		return
	if(next_damage < time):
		do_flash(Color.RED)
		var oldHP = Health
		Health -= dmg
		health_changed.emit(int(oldHP), int(Health))
		next_damage = time + 0.4
	if(Health <= 0):
		do_death()
		player_died.emit()
