extends Label

@export var bar: ProgressBar


func _on_bar_value_changed(_v) -> void:
	update_text()


func _on_unit_is_changed() -> void:
	update_text()


func update_text() -> void:
	text = str(bar.get_value()) + "/" + str(bar.get_max())
