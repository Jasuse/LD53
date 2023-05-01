extends Node

@onready var hp_panel : ProgressBar = $HBoxContainer/HPPanel

@onready var power = $HBoxContainer/Power
@onready var power_2 = $HBoxContainer/Power2
@onready var power_3 = $HBoxContainer/Power3


var power_pbs : Array[ProgressBar]
# Called when the node enters the scene tree for the first time.
func _ready():
	power_pbs.push_back(power)
	power_pbs.push_back(power_2)
	power_pbs.push_back(power_3)


func health_changed(oldHP, newHP):
	hp_panel.value = newHP

	for idx in power_pbs.size():
		if(newHP > 100):
			var value = (newHP % 100) - 25*idx
			power_pbs[idx].value = value
			if(value <= 0):
				power_pbs[idx].visible = false
			else:
				power_pbs[idx].visible = true
		else:
			power_pbs[idx].value = 0
			power_pbs[idx].visible = false
