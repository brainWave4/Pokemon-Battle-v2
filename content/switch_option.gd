extends PanelContainer

signal pressed


func _on_button_pressed() -> void:
	pressed.emit()


func set_unit(unit: BattleUnit) -> void:
	$VBoxContainer/Name.set_text(unit.name)
	
	var cur_hp: int = unit.cur_hp
	var max_hp: int = unit.max_hp
	
	var hp_bar: ProgressBar = $VBoxContainer/ProgressBar
	hp_bar.set_max(max_hp)
	hp_bar.set_value_no_signal(cur_hp)
	
	$VBoxContainer/HP.set_text(str(cur_hp) + "/" + str(max_hp))
