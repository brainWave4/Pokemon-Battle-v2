extends Button

signal approved_pressed

@export var your_side: UnitSide

@export var team: VBoxContainer

func _pressed() -> void:
	var selected_unit: BattleUnit = team.selected_unit
	
	if your_side.has_unit_out_in_battle(selected_unit):
		print("Already in battle")
	elif selected_unit.cur_hp <= 0:
		print("Not enough HP")
	else:
		approved_pressed.emit()
