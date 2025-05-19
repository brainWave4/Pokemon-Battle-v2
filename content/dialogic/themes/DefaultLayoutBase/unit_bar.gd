extends PanelContainer
class_name UnitBar

signal hp_tween_finished

func _on_unit_hp_changed(cur_hp: int) -> void:
	var bar_tween := create_tween()
	bar_tween.tween_property(%HP_Bar, "value", cur_hp, 1.0)
	bar_tween.tween_callback(func ():
		hp_tween_finished.emit()
		)
