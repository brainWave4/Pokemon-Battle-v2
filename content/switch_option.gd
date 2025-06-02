extends PanelContainer
class_name SwitchOption

signal pressed
signal unit_is_selected(unit: BattleUnit)

var battle_unit: BattleUnit

func _on_button_pressed() -> void:
	pressed.emit()
	unit_is_selected.emit(battle_unit)


func set_unit(unit: BattleUnit) -> void:
	battle_unit = unit
	
	$VBoxContainer/Name.set_text(unit.name)
	
	var cur_hp: int = unit.cur_hp
	var max_hp: int = unit.max_hp
	
	var hp_bar: ProgressBar = $VBoxContainer/ProgressBar
	hp_bar.set_max(max_hp)
	hp_bar.set_value_no_signal(cur_hp)
	
	$VBoxContainer/HP.set_text(str(cur_hp) + "/" + str(max_hp))
