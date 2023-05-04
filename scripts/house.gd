extends Node

signal ended_sequence

@onready var animplayer = $AnimationPlayer
@export var IsRandom : bool = false
@export var GuaranteedOutcome : bool = false
@export var ShouldTrigger : bool = false
@onready var area_2d = $Area2D

var triggered : bool = false
@onready var pop = $pop

func _ready():
	if(ShouldTrigger):
		area_2d._enable_monitoring()

func do_anim():
	GameInstance.player.controlled = true
	GameInstance.player.do_knock_anim()
	animplayer.play("knock_animation")

func _enable_triggering():
	area_2d._enable_monitoring()

func make_player_offer(backward : bool):
	GameInstance.player.do_offer(backward)

func make_player_reset():
	GameInstance.player.animation_player.play("RESET")

func enable_player_animtree():
	GameInstance.player.enable_animtree()

func _on_area_2d_trigger_entered():
	do_anim()

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "knock_animation"):
		if(IsRandom):
			var isgood = randi() > 50
			if(isgood):
				animplayer.play("package_accept")
				pop.play()
			else:
				animplayer.play("package_reject")
		else:
			if(GuaranteedOutcome):
				animplayer.play("package_accept")
				pop.play()
			else:
				animplayer.play("package_reject")
				print("should reject")
				
	if(anim_name == "package_reject" || anim_name == "package_accept"):
		GameInstance.player.controlled = false
		ended_sequence.emit()




