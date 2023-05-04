extends Area2D

signal trigger_entered

@export var ShouldTrigger : bool = false
var triggered : bool = false


func _enable_monitoring():
	ShouldTrigger = true
	if(triggered):
		set_deferred("monitoring", false)
		trigger_entered.emit()

func _on_body_entered(body):
	if(body == GameInstance.player):
		triggered = true
		print("player entered")
		if(ShouldTrigger):
			trigger_entered.emit()
			set_deferred("monitoring", false)

func _on_body_exited(body):
	if(body == GameInstance.player):
		triggered = false
