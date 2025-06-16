extends Button

signal approved_pressed

@export var main: Node

@export var your_side: UnitSide

@export var team: VBoxContainer

@export var error_textbox: DialogicLayoutLayer

@export_group("Timelines")

## Timeline when the unit is already in battle
@export var timeline_already_in: DialogicTimeline

## Timeline when the unit is unable to battle due
## to having 0 HP.
@export var timeline_no_hp: DialogicTimeline

func _pressed() -> void:
	var selected_unit: BattleUnit = team.selected_unit
	
	if your_side.has_unit_out_in_battle(selected_unit):
		show_error(timeline_already_in)
	elif selected_unit.cur_hp <= 0:
		show_error(timeline_no_hp)
	else:
		approved_pressed.emit()


func show_error(timeline: DialogicTimeline) -> void:
	main.change_textbox(1)
	error_textbox.show()
	Dialogic.start_timeline(timeline)
	
	await Dialogic.timeline_ended
	main.change_textbox(0)
	error_textbox.hide()
