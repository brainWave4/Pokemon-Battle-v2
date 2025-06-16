extends PanelContainer
class_name UnitBar

signal unit_is_changed

signal hp_tween_finished

func _on_unit_hp_changed(cur_hp: int) -> void:
	var bar_tween := create_tween()
	bar_tween.tween_property(%HP_Bar, "value", cur_hp, 1.0)
	bar_tween.tween_callback(func ():
		hp_tween_finished.emit()
		)


func set_unit(val: BattleUnit) -> void:
	$VBoxContainer/Name.set_text(val.name)
	%HP_Bar.set_max(val.max_hp)
	%HP_Bar.set_value_no_signal(val.cur_hp)
	
	unit_is_changed.emit()
	
	show()
